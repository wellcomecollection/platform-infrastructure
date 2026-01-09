from __future__ import annotations

from typing import Optional

from slack_alerts_local.runner import SPECS, run_handler


def auth0(argv: Optional[list[str]] = None) -> None:
    run_handler(SPECS["auth0"], argv)


def ecs_tasks(argv: Optional[list[str]] = None) -> None:
    run_handler(SPECS["ecs_tasks"], argv)


def lambda_errors(argv: Optional[list[str]] = None) -> None:
    run_handler(SPECS["lambda_errors"], argv)


def metric(argv: Optional[list[str]] = None) -> None:
    run_handler(SPECS["metric"], argv)
