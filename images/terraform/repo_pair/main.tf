resource "aws_ecr_repository" "private" {
  name = "${var.namespace}/${var.repo_name}"
}

resource "aws_ecrpublic_repository" "public" {
  provider = aws.ecr_public

  repository_name = var.repo_name

  catalog_data {
    about_text      = var.description
    logo_image_blob = filebase64("weco.png")
  }
}
