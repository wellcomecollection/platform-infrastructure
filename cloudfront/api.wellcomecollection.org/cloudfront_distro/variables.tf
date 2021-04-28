variable "acm_certificate_arn" {
  type = string
}

variable "aliases" {
  type = list(string)
}

variable "comment" {
  type = string
}

variable "origin_domains" {
  type = object({
    catalogue     = string
    catalogue_old = string
    stacks        = string
    storage       = string
    text          = string
  })
}
