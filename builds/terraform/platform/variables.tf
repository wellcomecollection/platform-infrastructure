variable "repo_name" {}
variable "infra_bucket_arn" {}
variable "sbt_releases_bucket_arn" {}
variable "assumable_ci_roles" {
  type = list(string)
}
variable "publish_topics" {
  type = list(string)
}
