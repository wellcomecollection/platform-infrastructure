#!/usr/bin/env python3
# -*- encoding: utf-8
"""
This script does autoformatting in Buildkite on pull requests.

In particular, it runs the 'make format' task, and if there are any changes,
it pushes a new commit to your pull request and aborts the current build.
"""

import os
import subprocess
import sys

from commands import git
from git_utils import get_changed_paths
from provider import current_branch, repo


if __name__ == "__main__":
    root = git("rev-parse", "--show-toplevel")
    home = os.environ['HOME']

    subprocess.check_call(f"""
        docker run --tty --rm \
            --volume {os.path.join(home, '.aws')}:/root/.aws \
            --volume {root}:/repo \
            --workdir /repo \
            760097843905.dkr.ecr.eu-west-1.amazonaws.com/hashicorp/terraform:light fmt -recursive
    """.strip(), shell=True)

    subprocess.check_call(f"""
        docker run --tty --rm \
            --volume {root}:/repo \
            760097843905.dkr.ecr.eu-west-1.amazonaws.com/wellcome/format_python:112
    """.strip(), shell=True)

    # If there are any changes, push to GitHub immediately and fail the
    # build.  This will abort the remaining jobs, and trigger a new build
    # with the reformatted code.
    if get_changed_paths():
        print("*** There were changes from formatting, creating a commit")

        git("config", "user.name", "Buildkite on behalf of Wellcome Collection")
        git("config", "user.email", "wellcomedigitalplatform@wellcome.ac.uk")
        git("remote", "add", "ssh-origin", repo(), exit_on_error=False)

        # We checkout the branch before we add the commit, so we don't
        # include the merge commit that Buildkite makes.
        git("fetch", "ssh-origin")
        git("checkout", "--track", f"ssh-origin/{current_branch()}")

        git("add", "--verbose", "--update")
        git("commit", "-m", "Apply auto-formatting rules")
        git("push", "ssh-origin", f"HEAD:{current_branch()}")

        # We exit here to fail the build, so Buildkite will skip to the next
        # build, which includes the autoformat commit.
        sys.exit(1)
    else:
        print("*** There were no changes from auto-formatting")

    # Run the 'lint' tasks.  A failure in these tasks requires
    # manual intervention, so we run them second to get any automatic fixes
    # out of the way.
    subprocess.check_call(f"""
        docker run --tty --rm \
            --volume {root}:/repo \
            --workdir /repo \
            760097843905.dkr.ecr.eu-west-1.amazonaws.com/wellcome/flake8:latest \
            --exclude .git,__pycache__,target,.terraform --ignore=E501,E122,E126,E203,W503
    """)
