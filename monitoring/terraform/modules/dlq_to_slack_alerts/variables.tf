variable "account_name" {
  type = string
}

variable "infra_bucket" {
  type = string
}

variable "copy_secrets" {
  type    = bool
  default = true
}

variable "alarm_topic_arn" {
  type = string
}
