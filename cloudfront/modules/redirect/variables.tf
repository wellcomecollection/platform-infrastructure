variable "zone_id" {
  description = "The domain zone ID"
}

variable "from" {
  description = "Which domain to redirect from"
}

variable "to" {
  description = "The hostname of the domain to redirect to"
  type        = string
}
