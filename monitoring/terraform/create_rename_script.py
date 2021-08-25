#!/usr/bin/env python

import collections
import json
import subprocess


if __name__ == '__main__':
    subprocess.check_call(["terraform", "plan", "-out", "terraform.plan"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    tfplan = json.loads(
        subprocess.check_output(["terraform", "show", "-json", "terraform.plan"])
    )

    created_resources = collections.defaultdict(list)
    deleted_resources = collections.defaultdict(list)

    for resource in tfplan["resource_changes"]:
        if all(act in {"no-op", "update", "read"} for act in resource["change"]["actions"]):
            continue

        resource_address = resource["address"]
        resource_type = resource_address.split(".")[-2]

        if resource["change"]["actions"] == ["create"]:
            created_resources[resource_type].append(resource_address)

        if resource["change"]["actions"] == ["delete"]:
            deleted_resources[resource_type].append(resource_address)

    for resource_type, deleted in deleted_resources.items():
        created = created_resources[resource_type]
        if len(deleted) == len(created):
            for d, c in zip(sorted(deleted), sorted(created)):
                print("terraform state mv", d, c)

