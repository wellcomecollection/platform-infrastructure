variable "service" {}
variable "vpc_id" {}

variable "security_group_ids" {
  type = "list"
}

variable "subnet_ids" {
  type = "list"
}
