variable "id" {
  type = string
}

variable "prod" {
  type = object({
    domain_name: string
    origin_path: string
  })
}
variable "stage" {
  type = object({
    domain_name: string
    origin_path: string
  })
}
variable "test" {
  type = object({
    domain_name: string
    origin_path: string
  })
}

output "origins" {
  value = {
    prod: {
      origin_id = var.id
      domain_name = var.prod.domain_name
      origin_path = var.prod.origin_path
    },
    stage: {
      origin_id = var.id
      domain_name = var.stage.domain_name
      origin_path = var.stage.origin_path
    },
    test: {
      origin_id = var.id
      domain_name = var.test.domain_name
      origin_path = var.test.origin_path
    }
  }
}
