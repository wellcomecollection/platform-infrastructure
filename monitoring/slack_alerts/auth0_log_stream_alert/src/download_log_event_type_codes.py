#!/usr/bin/env python3
"""
This script creates the JSON file ``log_event_type_codes.json``.

This file is used by the Lambda to interpret the log event type, and
provide the longer explanation in the Slack message.

You only need to re-run this script if Auth0 add new codes; it's kept
for posterity, rather than something I expect to be used as part of
normal operations.

"""

import json

import bs4
import httpx

if __name__ == "__main__":
    resp = httpx.get("https://auth0.com/docs/deploy-monitor/logs/log-event-type-codes")
    resp.raise_for_status()

    html = resp.text

    soup = bs4.BeautifulSoup(html, "html.parser")

    table = soup.find("article").find("table")

    codes = {}

    for row in table.find_all("tr"):
        # header row
        if row.find("td") is None:
            continue

        event_code, event, description = row.find_all("td")

        codes[event_code.text] = event.text

    with open("log_event_type_codes.json", "w") as outfile:
        outfile.write(json.dumps(codes, indent=2, sort_keys=True))
