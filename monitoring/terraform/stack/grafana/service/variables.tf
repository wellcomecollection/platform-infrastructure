variable "service_name" {}
variable "cluster_arn" {}

variable "desired_task_count" {
  default = 1
}

variable "task_definition_arn" {}

variable "subnets" {
  type = list(string)
}

variable "namespace_id" {
  default = "ecs"
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "deployment_minimum_healthy_percent" {
  default = 100
}

variable "deployment_maximum_percent" {
  default = 200
}

variable "service_discovery_failure_threshold" {
  default = 1
}

variable "launch_type" {
  type = string
}

variable "target_group_arn" {
  default = ""
}

variable "container_name" {
  default = ""
}

variable "container_port" {
  default = ""
}

variable "use_fargate_spot" {
  type    = bool
  default = false
}
