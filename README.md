# Platform Infrastructure

[![Build status](https://badge.buildkite.com/77ed104b8415c0879a234231e0fa3eebde5adf34f434b9ba9a.svg?branch=master)](https://buildkite.com/wellcomecollection/platform-infrastructure)

Wellcome Collection common infrastructure.

- [accounts](accounts/README.md): AWS account configuration, IAM etc.

- [assets](assets/README.md): Infrastructure for managing S3 buckets that contain "assets" (files or documents that are irretrievable).

- [images](images/README.md): Shared container definitions & repos (e.g. fluentbit, nginx).

- [critical](critical/README.md): Shared infrastructure for all projects, split into user_facing (api/cognito) and back_end (logs, shared config, networking).

- [cloudfront](cloudfront/README.md): Managing the infrastructure for Wellcome Collection's CloudFront distributions & DNS.

- [monitoring](monitoring/README.md): Grafana platform monitoring stack.

- **photography_backups**: Backup storage for photography (needs cleanup?)

## No longer in this repo

Some of the subdirectories of this repo have been broken out into their own repositories, to make them easier to find:

*   `builds` is now the [buildkite-infrastructure](https://github.com/wellcomecollection/buildkite-infrastructure) repository
*   `cloudfront/wellcomelibrary.org` is now the [wellcomelibrary.org](https://github.com/wellcomecollection/wellcomelibrary.org) repository
*   `cost_reporter` is now [a standalone repo of the same name](https://github.com/wellcomecollection/cost_reporter)
