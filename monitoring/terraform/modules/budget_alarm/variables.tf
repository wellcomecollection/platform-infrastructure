variable "budget_name" {
  type        = string
  description = "Name for the budget"
  default     = "monthly-budget"
}

variable "alarm_actions" {
  type        = list(string)
  description = "List of ARNs to notify when alarms are triggered"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
