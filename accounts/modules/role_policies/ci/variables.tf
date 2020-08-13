variable "role_name" {
  type = string
}
variable "sbt_releases_bucket_arn" {
  type = string
}
variable "infra_bucket_arn" {
  type = string
  default = ""
}
variable "aws_region" {
  type = string
  default = "eu-west-1"
}