#!/usr/bin/env python3
"""
This script autogenerates the credentials.ini file in this folder.

It doesn't need to be run very often; just when we add or remove AWS accounts.
You could assemble it by hand or by following the README; this was just
a tad faster.
"""

import itertools

import bs4


def get_account_names_and_ids(soup):
    accounts_table = soup.find("table", attrs={"id": "accounts"})

    for tr in accounts_table.find_all("tr"):

        # Skip the header row
        if tr.find("th") is not None:
            continue

        account_name = tr.find_all("td")[0].text
        account_id = tr.find_all("td")[1].text

        # This is a standalone account which isn't part of our fancy role
        # setup.
        if account_name == "microsites":
            continue

        yield (account_name, account_id)


def get_role_suffixes(soup):
    roles_table = soup.find("table", attrs={"id": "roles"})

    for tr in roles_table.find_all("tr"):

        # Skip the header row
        if tr.find("th") is not None:
            continue

        yield tr.find_all("td")[0].text


if __name__ == "__main__":
    soup = bs4.BeautifulSoup(open("../README.md"), "html.parser")

    account_names_and_ids = list(get_account_names_and_ids(soup))
    role_suffixes = list(get_role_suffixes(soup))

    for ((account_name, account_id), role_suffix) in itertools.product(
        account_names_and_ids, role_suffixes
    ):
        print(
            f"""
[{account_name}-{role_suffix}]
role_arn=arn:aws:iam::{account_id}:role/{account_name}-{role_suffix}
source_profile=default
region=eu-west-1
""".strip()
            + "\n"
        )
