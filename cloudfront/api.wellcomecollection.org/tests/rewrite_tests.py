#!/usr/bin/env python3

import click
import requests
import re
import uuid


def get_url(uri, expected_status=200):
    r = requests.get(uri + "?cacheBust=" + str(uuid.uuid1()))

    if r.status_code != expected_status:
        click.echo(
            click.style(
                f"Status code fail - expected '{expected_status}' but got '{r.status_code}'",
                fg="red",
            )
        )
    else:
        click.echo(
            click.style(f"Status code as expected - '{r.status_code}'", fg="green")
        )


def run_checks(env_suffix=""):
    urls_to_check = [
        f"https://api{env_suffix}.wellcomecollection.org/text/v1/b28957556",
        f"https://api{env_suffix}.wellcomecollection.org/text/v1/b28957556.zip",
        f"https://api{env_suffix}.wellcomecollection.org/text/alto/b28957556/b28957556_0001.jp2",
    ]

    # validate 200 response for above
    click.echo()
    click.echo(click.style(f"Validating urls", fg="white", bold=True))
    for url in urls_to_check:
        click.echo(click.style(f"Checking: {url}", fg="white", underline=True))
        get_url(url)


@click.command()
@click.option("--env", default="prod", help="Environment to check (stage|prod)")
def check_api(env):
    if env == "stage":
        run_checks("-stage")
    else:
        run_checks()


if __name__ == "__main__":
    check_api()
