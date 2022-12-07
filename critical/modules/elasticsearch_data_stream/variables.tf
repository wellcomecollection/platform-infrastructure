variable "stream_name" {
  type = string
}

variable "index_rollover_max_age" {
  type    = string
  default = "1d"
}

variable "index_delete_after" {
  type    = string
  default = "30d"
}
