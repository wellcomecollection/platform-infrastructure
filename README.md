# Platform Infrastructure

Wellcome Collection common infrastructure.

- [accounts](accounts/README.md): AWS account configuration, IAM etc.

- [assets](assets/README.md): Infrastructure for managing S3 buckets that contain "assets" (files or documents that are irretrievable).

- [builds](builds/README.md): Infrastructure for CI (mostly IAM for build agents).

- [images](images/README.md): Shared container definitions & repos (e.g. fluentbit, nginx).

- [critical](critical/README.md): Shared infrastructure for all projects, split into user_facing (api/cognito) and back_end (logs, shared config, networking).

- [dns](dns/README.md): Managing the infrastructure for Wellcome Collection's DNS.

- [monitoring](monitoring/README.md): Grafana platform monitoring stack.

- **photography_backups**: Backup storage for photography (needs cleanup?)

- **digitisation_infra**: Digital production infrastructure.



## Third-party code

*   The `nat_instance` module used in `critical/back_end` is based on [int128/terraform-aws-nat-instance](https://github.com/int128/terraform-aws-nat-instance/tree/1a6398adbe242fc8d3ca1efe22090ad7fe195a98), used under the Apache licence.
