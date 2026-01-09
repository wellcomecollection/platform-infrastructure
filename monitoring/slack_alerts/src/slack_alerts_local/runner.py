import argparse
import contextlib
import json
import os
import sys
import types
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Callable, Dict, Iterator, Optional


@dataclass(frozen=True)
class HandlerSpec:
    cli_name: str
    module_name: str
    src_dir: Path
    # Patch the module so secret lookup returns the provided webhook URL.
    patch_webhook_lookup: Callable[[types.ModuleType, str], None]
    # Environment keys we want to ensure exist for local runs.
    default_env: Dict[str, str]


def _parse_kv_pairs(pairs: list[str]) -> dict[str, str]:
    result: dict[str, str] = {}
    for p in pairs:
        if p.find("=") < 1:
            raise ValueError(f"Invalid --set-env value {p!r}; expected KEY=VALUE")
        k, v = p.split("=", 1)
        result[k] = v
    return result


def load_event(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


@contextlib.contextmanager
def prepend_sys_path(path: Path) -> Iterator[None]:
    sys.path.insert(0, str(path))
    try:
        yield
    finally:
        try:
            sys.path.remove(str(path))
        except ValueError:
            pass


class _DummyHTTPResponse:
    def __init__(self, body: bytes = b"") -> None:
        self._body = body

    def read(self) -> bytes:
        return self._body


@contextlib.contextmanager
def dry_run_urlopen(enabled: bool) -> Iterator[None]:
    if not enabled:
        yield
        return

    original = urllib.request.urlopen

    def _urlopen(req: urllib.request.Request, *args: Any, **kwargs: Any) -> _DummyHTTPResponse:  # type: ignore[override]
        url = getattr(req, "full_url", None) or getattr(req, "url", "<unknown>")
        data = getattr(req, "data", None)
        headers = getattr(req, "headers", {})

        print("[dry-run] Would POST to Slack webhook")
        print(f"[dry-run] URL: {url}")
        if headers:
            print(f"[dry-run] Headers: {dict(headers)}")
        if data is not None:
            try:
                decoded = data.decode("utf-8")
            except Exception:
                decoded = repr(data)
            print(f"[dry-run] Body: {decoded}")

        return _DummyHTTPResponse()

    urllib.request.urlopen = _urlopen  # type: ignore[assignment]
    try:
        yield
    finally:
        urllib.request.urlopen = original  # type: ignore[assignment]


def run_handler(spec: HandlerSpec, argv: Optional[list[str]] = None) -> None:
    parser = argparse.ArgumentParser(prog=spec.cli_name)
    parser.add_argument(
        "--event",
        required=True,
        type=Path,
        help="Path to a JSON file containing the Lambda event payload.",
    )
    parser.add_argument(
        "--send",
        action="store_true",
        help="Actually send to Slack. If omitted, runs in dry-run mode (no network).",
    )
    parser.add_argument(
        "--webhook-url",
        help=(
            "Override the Slack webhook URL used by the handler. "
            "If omitted, the handler may call AWS Secrets Manager."
        ),
    )
    parser.add_argument(
        "--account-name",
        default=os.environ.get("ACCOUNT_NAME", "local"),
        help="Value for ACCOUNT_NAME env var (default: local).",
    )
    parser.add_argument(
        "--aws-region",
        default=os.environ.get("AWS_REGION", "eu-west-1"),
        help="Value for AWS_REGION env var (default: eu-west-1).",
    )
    parser.add_argument(
        "--set-env",
        action="append",
        default=[],
        metavar="KEY=VALUE",
        help="Additional environment variables to set (repeatable).",
    )

    args = parser.parse_args(argv)

    # Establish baseline env.
    os.environ.setdefault("ACCOUNT_NAME", args.account_name)
    os.environ.setdefault("AWS_REGION", args.aws_region)
    for k, v in spec.default_env.items():
        os.environ.setdefault(k, v)

    extra_env = _parse_kv_pairs(args.set_env)
    for k, v in extra_env.items():
        os.environ[k] = v

    event = load_event(args.event)

    send_enabled = bool(args.send)
    # Patch urlopen *before* importing the handler module.
    # This ensures handlers that do `from urllib.request import urlopen` bind to
    # the patched function during import in dry-run mode.
    with dry_run_urlopen(enabled=not send_enabled):
        with prepend_sys_path(spec.src_dir):
            module = __import__(spec.module_name)

            if args.webhook_url:
                spec.patch_webhook_lookup(module, args.webhook_url)

            # All handlers in this folder use `main(event, _ctxt=None)`.
            module.main(event, None)


def _root_dir() -> Path:
    # .../monitoring/slack_alerts/src/slack_alerts_local/runner.py
    # parents[0] = slack_alerts_local/, parents[1] = src/, parents[2] = slack_alerts/
    return Path(__file__).resolve().parents[2]


def _patch_get_secret_string_simple(module: types.ModuleType, webhook_url: str) -> None:
    # Handlers with: get_secret_string(*, secret_id)
    if hasattr(module, "get_secret_string"):
        setattr(module, "get_secret_string", lambda *args, **kwargs: webhook_url)


def _patch_get_secret_string_ecs(module: types.ModuleType, webhook_url: str) -> None:
    # ecs_tasks_cant_start_alert has: get_secret_string(sess, *, secret_id)
    if hasattr(module, "get_secret_string"):

        def _get_secret_string(_sess: Any, *, secret_id: str) -> str:
            return webhook_url

        setattr(module, "get_secret_string", _get_secret_string)


SPECS: dict[str, HandlerSpec] = {
    "auth0": HandlerSpec(
        cli_name="slack-alert-auth0",
        module_name="auth0_log_stream_alert",
        src_dir=_root_dir() / "auth0_log_stream_alert" / "src",
        patch_webhook_lookup=_patch_get_secret_string_simple,
        default_env={},
    ),
    "ecs_tasks": HandlerSpec(
        cli_name="slack-alert-ecs-tasks",
        module_name="ecs_tasks_cant_start_alert",
        src_dir=_root_dir() / "ecs_tasks_cant_start_alert" / "src",
        patch_webhook_lookup=_patch_get_secret_string_ecs,
        default_env={},
    ),
    "lambda_errors": HandlerSpec(
        cli_name="slack-alert-lambda-errors",
        module_name="lambda_errors_to_slack_alerts",
        src_dir=_root_dir() / "lambda_errors_to_slack_alerts" / "src",
        patch_webhook_lookup=_patch_get_secret_string_simple,
        default_env={},
    ),
    "metric": HandlerSpec(
        cli_name="slack-alert-metric",
        module_name="metric_to_slack_alert",
        src_dir=_root_dir() / "metric_to_slack_alert" / "src",
        patch_webhook_lookup=_patch_get_secret_string_simple,
        # Provide a safe minimal baseline; most values are supplied by Terraform
        # in the deployed Lambdas. For local runs you can override via --set-env.
        default_env={
            "STR_SINGLE_ERROR_MESSAGE": "There was 1 error",
            "STR_MULTIPLE_ERROR_MESSAGE": "There were {error_count} errors",
            "STR_ALARM_SLUG": "metric-alert",
            "STR_ALARM_LEVEL": "warning",
        },
    ),
}
