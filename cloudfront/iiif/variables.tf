variable "environment" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "dlcs_lambda_associations" {
  default = []

  type = list(object({
    event_type = string
    lambda_arn = string
  }))
}

variable "miro_sourced_images_target" {
  default = "loris"
}
