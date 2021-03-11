output "traffic_filter_vpce_id" {
  value = ec_deployment_traffic_filter.allow_vpce.id
}

output "security_group_id" {
  value = aws_security_group.allow_elastic_cloud_vpce.id
}
