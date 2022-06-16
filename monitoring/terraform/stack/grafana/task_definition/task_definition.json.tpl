[
  {
    "cpu": ${cpu},
    "memory": ${memory},
    "essential": true,
    "image": "${container_image}",
    "name": "${container_name}",
    "environment": ${environment_vars},
    "secrets": ${secrets},
    "networkMode": "awsvpc",
    "command": ${command},
    %{ if port_mappings_defined }
    "portMappings": ${port_mappings},
    %{ endif }
    %{ if use_aws_logs }
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${log_group_name}",
            "awslogs-region": "${log_group_region}",
            "awslogs-stream-prefix": "${log_group_prefix}"
        }
    },
    %{ endif }
    "user": "${user}",
    "mountPoints": ${mount_points}
  }
]