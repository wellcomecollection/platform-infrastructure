variable "account_name" {
  description = "Name of the AWS account for budget resources"
  type        = string
}

variable "budget_multiplier" {
  description = "Multiplier for the maximum budget threshold (e.g., 1.1 for 110%)"
  type        = number
  default     = 1.1
}
