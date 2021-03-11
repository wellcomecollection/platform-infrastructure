variable "environment" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "default_target_origin_id" {
  type = string
}

variable "origins" {
  type = list(object({
    origin_id : string
    domain_name : string
    origin_path : string
    forward_host : bool
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
}
