variable "name" {
  description = "Name of the Lambda"
}

variable "module_name" {
  description = "Name of the python module where the handler function lives"
  default     = ""
}

variable "description" {
  description = "Description of the Lambda function"
}

variable "environment_variables" {
  description = "Environment variables to pass to the Lambda"
  type        = map(string)

  # environment cannot be empty so we need to pass at least one value
  default = {
    EMPTY_VARIABLE = ""
  }
}

variable "timeout" {
  description = "The amount of time your Lambda function has to run in seconds"
  default     = 3
}

variable "alarm_topic_arn" {
  description = "ARN of the topic where to send notification for lambda errors"
}

variable "filename" {
  type    = string
  default = ""
}

variable "memory_size" {
  default = 128
}

variable "log_retention_in_days" {
  description = "The number of days to keep CloudWatch logs"
  type        = number
  default     = 7
}
