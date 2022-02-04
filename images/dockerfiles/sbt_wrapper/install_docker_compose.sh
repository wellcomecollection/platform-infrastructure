#!/usr/bin/env bash

set -o errexit
set -o nounset

apt-get update
apt-get install --yes \
    apt-transport-https \
    ca-certificates \
    curl \
    libffi-dev \
    software-properties-common \
    python3 \
    python3-pip \
    python3-setuptools

curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install --yes docker-ce docker-ce-cli containerd.io
pip3 install docker-compose

# Remove some packages we no longer need once docker-compose is installed.
# This reduces the size of the final Docker image.
apt-get remove --yes \
    apt-transport-https \
    ca-certificates \
    curl \
    python3-pip

# This is to ensure you haven't deleted a critical package for running
# Docker Compose.  In particular, when trying to create this container,
# it would build successfully but fail when it tried to run Docker Compose:
#
#     Traceback (most recent call last):
#       File "/usr/local/bin/docker-compose", line 5, in <module>
#         from compose.cli.main import main
#       File "/usr/local/lib/python3.9/dist-packages/compose/cli/main.py", line 9, in <module>
#         from distutils.spawn import find_executable
#     ModuleNotFoundError: No module named 'distutils.spawn'
#
# The distutils library is installed by python3-setuptools, which is a
# dependency of python3-pip.  We don't need all of pip and its dependencies
# in the final image (which is nearly 300MB extra!), but we do need setuptools.
docker-compose --version

apt-get clean
apt-get autoremove --yes
