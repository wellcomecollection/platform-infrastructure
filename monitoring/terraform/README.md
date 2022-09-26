# Terraforming the monitoring infrastructure

## Grafana Loadbalancer Security Group

The Grafana loadbalancer security group is normally maintained manually, so changes are ignored by Terraform.
To reset it, change the ignore_changes definition in [security_groups.tf](stack/grafana/security_groups.tf).