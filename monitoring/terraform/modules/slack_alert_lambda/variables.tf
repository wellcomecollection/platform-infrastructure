variable "name" {
  type = string
}

variable "source_name" {
  type    = string
  default = ""
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}

variable "secrets" {
  type = list(string)
}

variable "description" {
  type = string
}

variable "account_name" {
  type = string
}

variable "alarm_topic_arn" {
  type = string
}
