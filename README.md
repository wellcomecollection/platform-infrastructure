# Platform Infrastructure

Wellcome Collection common infrastructure.

- [accounts](accounts/README.md): Provisioning AWS account access.
- [assets](assets/README.md): This is a minimal Terraform stack for managing S3 buckets that contain "assets" -- that is, files or documents that are irretrievable.
- [builds](builds/README.md): Provisioning infrastructure for CI.
- [containers](containers/README.md): Shared container definitions & repos (e.g. fluentbit, nginx).
- [critical](critical/README.md): Any infrastructure where extreme care must be taken to prevent deletion of data.
- [dns](dns/README.md): Managing the infrastructure for Wellcome Collection's DNS.
- [monitoring](monitoring/README.md): Grafana platform monitoring stack.
- **shared**: Everything else that has cross platform concerns e.g. logs, configuration, networking.
- **photography_backups**: Backup storage for photography (needs cleanup?)
- **digitisation_infra**: Digital production infrastructure.

