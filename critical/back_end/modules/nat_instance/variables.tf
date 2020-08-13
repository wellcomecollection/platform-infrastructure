variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet" {
  type = string
}

variable "cidr_block_private" {
  type = string
}

variable "private_subnet_route_table_id" {
  type = string
}

variable "instance_type" {
  type = string

  # The bandwidth on NAT instances depends on the bandwidth of the underlying
  # instances.  The default is a t3.medium ($0.0456/hr) because it's about the
  # same as a managed NAT Gateway ($0.048/hr), but without the per-GB costs.
  #
  # Increase the instance size if bandwidth becomes an issue.
  default = "t3.medium"
}
