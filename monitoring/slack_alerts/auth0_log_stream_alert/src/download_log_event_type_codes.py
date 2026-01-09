#!/usr/bin/env python3
"""
This script creates the JSON file ``log_event_type_codes.json``.

This file is used by the Lambda to interpret the log event type, and
provide the longer explanation in the Slack message.

You only need to re-run this script if Auth0 add new codes; it's kept
for posterity, rather than something I expect to be used as part of
normal operations.

Why scrape HTML with BeautifulSoup?

Auth0 don't currently publish a single machine-readable (e.g. JSON/XML)
resource that includes *both* the log event type code and the
human-friendly name we want to show in Slack.

There is a JSON schema with the ids and descriptions:
https://github.com/auth0/auth0-log-schemas/blob/main/schemas/all-log-types.schema.json

But the human-friendly name isn't present there; to derive it you'd need to
read each of the per-type files in:
https://github.com/auth0/auth0-log-schemas/tree/main/schemas/log-types

Until Auth0 publish a simpler API for this mapping, scraping the docs table
is the most straightforward way to keep our local
``log_event_type_codes.json`` up to date.
"""

import json
import re
from pathlib import Path
from typing import Dict, Optional

import bs4
import httpx

URL = "https://auth0.com/docs/deploy-monitor/logs/log-event-type-codes"


def _normalise(s: str) -> str:
    return " ".join(s.split())


def _extract_codes_from_table(table: bs4.Tag) -> Dict[str, str]:
    """Extract a mapping {event_code: event_name} from a HTML table.

    We deliberately ignore the description column because the Lambda only
    needs the human-friendly event name.
    """

    codes: Dict[str, str] = {}

    for row in table.find_all("tr"):
        tds = row.find_all("td")
        if len(tds) < 2:
            continue

        event_code = _normalise(tds[0].get_text(" ", strip=True))
        event_name = _normalise(tds[1].get_text(" ", strip=True))

        # Auth0 codes are short-ish identifiers like: "f", "api_limit", "gd_send_pn".
        if not re.match(r"^[A-Za-z0-9_]{1,40}$", event_code):
            continue
        if not event_name:
            continue

        codes[event_code] = event_name

    return codes


def _find_codes_table(soup: bs4.BeautifulSoup) -> Optional[Dict[str, str]]:
    """Find the best candidate table on the page that contains event codes."""
    best: Optional[Dict[str, str]] = None
    best_count = 0

    for table in soup.find_all("table"):
        codes = _extract_codes_from_table(table)
        if len(codes) > best_count:
            best = codes
            best_count = len(codes)

    # Heuristic: the real table should contain lots of codes.
    if best is None or best_count < 20:
        return None

    return best


def main() -> None:
    resp = httpx.get(URL, follow_redirects=True, timeout=30)
    resp.raise_for_status()

    soup = bs4.BeautifulSoup(resp.text, "html.parser")
    codes = _find_codes_table(soup)

    if codes is None:
        raise SystemExit(
            "Could not find the log event type codes table on the Auth0 docs page. "
            "The page structure may have changed. "
            f"URL: {URL}"
        )

    out_path = Path(__file__).with_name("log_event_type_codes.json")
    out_path.write_text(
        json.dumps(codes, indent=2, sort_keys=True) + "\n", encoding="utf-8"
    )
    print(f"Wrote {len(codes)} codes to {out_path}")


if __name__ == "__main__":
    main()
