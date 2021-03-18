variable "distro_alternative_names" {
  type = list(string)
}

variable "acm_certificate_arn" {
  type = string
}

variable "default_target_origin_id" {
  type = string
}

variable "default_lambda_function_association_event_type" {
  type = string
}
variable "default_lambda_function_association_lambda_arn" {
  type = string
}

variable "origins" {
  type = list(object({
    origin_id : string
    domain_name : string
    origin_path : string
  }))
}

variable "behaviours" {
  type = list(object({
    path_pattern : string
    target_origin_id : string
    headers : list(string)
    cookies : string
    lambdas : list(object({
      event_type : string
      lambda_arn : string
    }))
    min_ttl : number
    default_ttl : number
    max_ttl : number
  }))

  default = []
}
