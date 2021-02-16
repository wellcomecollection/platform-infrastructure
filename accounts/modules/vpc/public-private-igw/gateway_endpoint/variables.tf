variable "service" {}
variable "vpc_id" {}
variable "route_table_id" {}
variable "service_type" {
  type    = string
  default = "Gateway"
}