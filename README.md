# Platform Infrastructure

[![Build status](https://badge.buildkite.com/77ed104b8415c0879a234231e0fa3eebde5adf34f434b9ba9a.svg?branch=master)](https://buildkite.com/wellcomecollection/platform-infrastructure)

Wellcome Collection common infrastructure.

- [accounts](accounts/README.md): AWS account configuration, IAM etc.

- [assets](assets/README.md): Infrastructure for managing S3 buckets that contain "assets" (files or documents that are irretrievable).

- [builds](builds/README.md): Infrastructure for CI (mostly IAM for build agents).

- [images](images/README.md): Shared container definitions & repos (e.g. fluentbit, nginx).

- [critical](critical/README.md): Shared infrastructure for all projects, split into user_facing (api/cognito) and back_end (logs, shared config, networking).

- [dns](dns/README.md): Managing the infrastructure for Wellcome Collection's DNS.

- [monitoring](monitoring/README.md): Grafana platform monitoring stack.

- **photography_backups**: Backup storage for photography (needs cleanup?)
