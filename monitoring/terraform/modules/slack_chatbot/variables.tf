variable "configuration_name" {
  type = string
}

variable "slack_workspace_id" {
  type = string
}

variable "slack_channel_id" {
  type = string
}

variable "alarm_match_string" {
  type = string
  default = "*"
}