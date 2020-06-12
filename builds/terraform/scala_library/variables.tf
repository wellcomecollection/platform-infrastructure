variable "name" {
  description = "Name of the associated library e.g. 'storage'"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket used for releases"
  type        = string
}

variable "repo_name" {
  type    = string
  default = ""
}

variable "lib_names" {
  type = list(string)
}

variable "platform_read_only_role" {}