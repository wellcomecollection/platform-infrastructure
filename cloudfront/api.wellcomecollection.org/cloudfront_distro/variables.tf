variable "acm_certificate_arn" {
  type = string
}

variable "aliases" {
  type = list(string)
}

variable "comment" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "origin_domains" {
  type = object({
    catalogue = string
    storage   = string
    text      = string
  })
}

variable "root_s3_domain" {
  type = string
}