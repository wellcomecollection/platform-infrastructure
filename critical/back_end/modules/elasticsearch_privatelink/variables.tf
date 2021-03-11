variable "vpc_id" {
  type = string
}

variable "service_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "ec_vpce_domain" {
  type = string
}

variable "traffic_filter_name" {
  type = string
}
