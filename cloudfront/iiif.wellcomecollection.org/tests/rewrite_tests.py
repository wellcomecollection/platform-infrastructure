#!/usr/bin/env python3

import click
import requests
import re
import uuid


def get_json(uri, expected_status=200):
    r = requests.get(uri + "?cacheBust=" + str(uuid.uuid1()))

    if r.status_code != expected_status:
        click.echo(
            click.style(
                f"Status code fail - expected '{expected_status}' but got '{r.status_code}'",
                fg="red",
            )
        )
        return {}

    return r.json()


def validate_id(infojson, expected):
    info_id = infojson.get("@id", None)

    if info_id != expected:
        click.echo(
            click.style(
                f"Id fail - expected '{expected}' but found '{info_id}'", fg="red"
            )
        )
        return False
    else:
        click.echo(click.style(f"Found '{info_id}'", fg="green"))
        return True


def validate_auth(info_json, regex):
    p = re.compile(regex)

    def validate_service(json):
        if not json:
            return

        service_description = json.get("service", [])

        if "service" in service_description:
            for service in service_description["service"]:
                info_id = service.get("@id", None)
                if not p.match(info_id):
                    click.echo(
                        click.style(
                            f"Id fail - expected '{regex}' but found '{info_id}'",
                            fg="red",
                        )
                    )
                else:
                    click.echo(click.style(f"Found '{info_id}'", fg="green"))

                validate_service(service)

    validate_service(info_json)


def validate_redirect(uri, redirect_to):
    r = requests.get(uri + "?cacheBust=" + str(uuid.uuid1()), allow_redirects=False)

    if r.status_code != 302:
        click.echo(click.style(f"Request to '{uri}' wasn't a redirect", fg="red"))
        return False
    else:
        click.echo(click.style(f"Request to '{uri}' redirected.", fg="green"))

    location = r.headers.get("Location", None)
    if location != redirect_to:
        click.echo(
            click.style(
                f"Redirect location incorrect - expected '{redirect_to}' but found '{location}'",
                fg="red",
            )
        )
        return False

    return True


def validate_cors_headers(uri, origin):
    headers = {"Origin": origin} if origin else {}
    r = requests.get(uri + "?ccc=asd", headers=headers)

    if r.status_code != 200:
        click.echo(
            click.style(
                f"Status code fail - expected 200 but got '{r.status_code}'", fg="red"
            )
        )
        return

    if origin:
        h = r.headers.get("Access-Control-Allow-Origin", None)
        if not h:
            click.echo(
                click.style(
                    f"'Access-Control-Allow-Origin' header expected but not found",
                    fg="red",
                )
            )
            return
    elif "Access-Control-Allow-Origin" in r.headers:
        click.echo(
            click.style(
                f"'Access-Control-Allow-Origin' header not expected but found", fg="red"
            )
        )
        return

    click.echo(click.style(f"Request to '{uri}' has expected CORS.", fg="green"))


def run_checks(env_suffix=""):
    space = 5 if env_suffix == "" else 6
    id_checks = {
        # miro
        # wellcome_images_dlcs_behaviours
        f"https://iiif{env_suffix}.wellcomecollection.org/image/V0022459": f"https://iiif{env_suffix}.wellcomecollection.org/image/V0022459",  # miro root, wc.org
        f"https://iiif{env_suffix}.wellcomecollection.org/image/V0022459/info.json": f"https://iiif{env_suffix}.wellcomecollection.org/image/V0022459",  # miro info.json, wc.org
        f"https://dlcs.io/iiif-img/2/8/V0022459": f"https://dlcs.io/iiif-img/2/8/V0022459",  # miro root, dlcs.io
        f"https://dlcs.io/iiif-img/2/8/V0022459/info.json": f"https://dlcs.io/iiif-img/2/8/V0022459",  # miro info.json, dlcs.io
        # non-miro images
        # dlcs_images_behaviours
        f"https://iiif{env_suffix}.wellcomecollection.org/image/b31905560_0006.jp2": f"https://iiif{env_suffix}.wellcomecollection.org/image/b31905560_0006.jp2",  # non-miro root, wc.org
        f"https://iiif{env_suffix}.wellcomecollection.org/image/b31905560_0006.jp2/info.json": f"https://iiif{env_suffix}.wellcomecollection.org/image/b31905560_0006.jp2",  # non-miro info.json, wc.org
        f"https://dlcs.io/iiif-img/2/{space}/b31905560_0006.jp2": f"https://dlcs.io/iiif-img/2/{space}/b31905560_0006.jp2",  # non-miro root, dlcs.io
        f"https://dlcs.io/iiif-img/2/{space}/b31905560_0006.jp2/info.json": f"https://dlcs.io/iiif-img/2/{space}/b31905560_0006.jp2",  # non-miro info.json, dlcs.io
        # video
        # av_behaviours
        f"https://iiif{env_suffix}.wellcomecollection.org/av/b16756654_0055-0000-4202-0000-0-0000-0000-0.mpg": f"https://iiif{env_suffix}.wellcomecollection.org/av/b16756654_0055-0000-4202-0000-0-0000-0000-0.mpg",  # root, wc.org
        f"https://iiif{env_suffix}.wellcomecollection.org/av/b16756654_0055-0000-4202-0000-0-0000-0000-0.mpg/info.json": f"https://iiif{env_suffix}.wellcomecollection.org/av/b16756654_0055-0000-4202-0000-0-0000-0000-0.mpg",  # info.json, wc.org
        f"https://dlcs.io/iiif-av/2/{space}/b16756654_0055-0000-4202-0000-0-0000-0000-0.mpg": f"https://dlcs.io/iiif-av/2/{space}/b16756654_0055-0000-4202-0000-0-0000-0000-0.mpg",  # root, dlcs.io
        f"https://dlcs.io/iiif-av/2/{space}/b16756654_0055-0000-4202-0000-0-0000-0000-0.mpg/info.json": f"https://dlcs.io/iiif-av/2/{space}/b16756654_0055-0000-4202-0000-0-0000-0000-0.mpg",  # info.json, dlcs.io
        # audio
        # av_behaviours
        f"https://iiif{env_suffix}.wellcomecollection.org/av/b32496485_0001_0001.mp3": f"https://iiif{env_suffix}.wellcomecollection.org/av/b32496485_0001_0001.mp3",  # root, wc.org
        f"https://iiif{env_suffix}.wellcomecollection.org/av/b32496485_0001_0001.mp3/info.json": f"https://iiif{env_suffix}.wellcomecollection.org/av/b32496485_0001_0001.mp3",  # info.json, wc.org
        f"https://dlcs.io/iiif-av/2/{space}/b32496485_0001_0001.mp3": f"https://dlcs.io/iiif-av/2/{space}/b32496485_0001_0001.mp3",  # root, dlcs.io
        f"https://dlcs.io/iiif-av/2/{space}/b32496485_0001_0001.mp3/info.json": f"https://dlcs.io/iiif-av/2/{space}/b32496485_0001_0001.mp3",  # info.json, dlcs.io
    }

    # validate info.json @id correct
    click.echo()
    click.echo(click.style(f"Validating info.json @id correct", fg="white", bold=True))
    for url, expected in id_checks.items():
        click.echo(click.style(f"Checking: {url}", fg="white", underline=True))
        info_json = get_json(url)
        validate_id(info_json, expected)

    # validate thumbs - reuse all images in id_checks but rewrite path for /thumbs/
    click.echo()
    click.echo(click.style(f"Validating thumbs correct", fg="white", bold=True))
    for url, expected in (i for i in id_checks.items() if "av/" not in i[0]):
        url = url.replace("/image/", "/thumbs/").replace("/iiif-img/", "/thumbs/")
        expected = expected.replace("/image/", "/thumbs/").replace(
            "/iiif-img/", "/thumbs/"
        )

        click.echo(click.style(f"Checking: {url}", fg="white", underline=True))
        info_json = get_json(url)
        validate_id(info_json, expected)

    # dlcs_images_behaviours
    authed_images = {
        f"https://iiif{env_suffix}.wellcomecollection.org/image/b19582183_RAMC_391_4_0001.jp2": f"https://iiif{env_suffix}.wellcomecollection.org/image/b19582183_RAMC_391_4_0001.jp2",  # non-miro root, wc.org
        f"https://iiif{env_suffix}.wellcomecollection.org/image/b19582183_RAMC_391_4_0001.jp2/info.json": f"https://iiif{env_suffix}.wellcomecollection.org/image/b19582183_RAMC_391_4_0001.jp2",
        # non-miro info.json, wc.org
        f"https://dlcs.io/iiif-img/2/{space}/b19582183_RAMC_391_4_0001.jp2": f"https://dlcs.io/iiif-img/2/{space}/b19582183_RAMC_391_4_0001.jp2",  # non-miro root, dlcs.io
        f"https://dlcs.io/iiif-img/2/{space}/b19582183_RAMC_391_4_0001.jp2/info.json": f"https://dlcs.io/iiif-img/2/{space}/b19582183_RAMC_391_4_0001.jp2",  # non-miro info.json, dlcs.io
    }

    # validate info.json @id correct and any authservices are correct
    click.echo()
    click.echo(
        click.style(
            f"Validating info.json @id correct and any authservices are correct",
            fg="white",
            bold=True,
        )
    )
    for url, expected in authed_images.items():
        click.echo(click.style(f"Checking: {url}", fg="white", underline=True))
        info_json = get_json(url, expected_status=401)
        validate_id(info_json, expected)

        auth_pattern = "https://dlcs.io/auth/2/.*"
        if url.startswith("https://iiif"):
            auth_pattern = (
                f"https://iiif{env_suffix}.wellcomecollection.org/auth/[ltc].*"
            )

        validate_auth(info_json, auth_pattern)

    # validate login attempts redirect to correct location
    # auth_behaviours
    auth_redirects = {
        f"https://iiif{env_suffix}.wellcomecollection.org/auth/clinicallogin": f"https://iiif{env_suffix}.wellcomecollection.org/roleprovider/dlcslogin",  # wc.org
        "https://dlcs.io/auth/2/clinicallogin": "https://wellcomelibrary.org/iiif/dlcslogin",  # current
    }

    click.echo()
    click.echo(click.style(f"Validating auth redirects", fg="white", bold=True))
    for url, expected in auth_redirects.items():
        click.echo(click.style(f"Checking: {url}", fg="white", underline=True))
        validate_redirect(url, expected)

    click.echo()
    click.echo(click.style(f"Validating CORS caching", fg="white", bold=True))
    origins = ["", "https://test.example.com"]
    for origin in origins:
        url = f"https://iiif{env_suffix}.wellcomecollection.org/presentation/b19582183"
        click.echo(
            click.style(
                f"Checking: {url} with origin {origin}", fg="white", underline=True
            )
        )
        validate_cors_headers(url, origin)


@click.command()
@click.option("--env", default="prod", help="Environment to check (stage|test|prod)")
def check_iiif(env):
    if env == "stage":
        run_checks("-stage")
    elif env == "test":
        run_checks("-test")
    else:
        run_checks()


if __name__ == "__main__":
    check_iiif()
