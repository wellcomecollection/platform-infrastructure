variable "name" {}
variable "federated_principal" {}
variable "aws_principal" {}

variable "assumable_role_arns" {
  type = list(string)
}

variable "max_session_duration_in_seconds" {
  type = number
  # 1 hour
  default = 60 * 60
}
