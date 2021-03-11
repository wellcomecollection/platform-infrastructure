variable "id" {
  type = string
}

variable "forward_host" {
  type    = bool
  default = false
}

variable "prod" {
  type = object({
    domain_name : string
    origin_path : string
  })
}
variable "stage" {
  type = object({
    domain_name : string
    origin_path : string
  })
}
variable "test" {
  type = object({
    domain_name : string
    origin_path : string
  })
}

output "origins" {
  value = {
    prod : {
      origin_id    = var.id
      domain_name  = var.prod.domain_name
      origin_path  = var.prod.origin_path
      forward_host = var.forward_host
    },
    stage : {
      origin_id    = var.id
      domain_name  = var.stage.domain_name
      origin_path  = var.stage.origin_path
      forward_host = var.forward_host
    },
    test : {
      origin_id    = var.id
      domain_name  = var.test.domain_name
      origin_path  = var.test.origin_path
      forward_host = var.forward_host
    }
  }
}
