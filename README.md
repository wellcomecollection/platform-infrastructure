# Platform Infrastructure

Various terraform stacks for handling Wellcome Collection digital platform infrastructure.

See:
- [critical](critical/README.md): Any infrastructure where extreme care must be taken to prevent deletion of data.
- [accounts](accounts/README.md): Provisioning AWS account access.
- [dns](dns/README.md): Managing the infrastructure for Wellcome Collection's DNS.
- [assets](assets/README.md): This is a minimal Terraform stack for managing S3 buckets that contain "assets" -- that is, files or documents that are irretrievable.
- **shared**: Everything else that has cross platform concerns e.g. logs, configuration, networking.
- **photography_backups**: Backup storage for photography (needs cleanup?)

