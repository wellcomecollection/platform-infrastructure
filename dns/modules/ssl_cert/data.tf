data "aws_route53_zone" "hostname_zone" {
  name     = "${var.hostname}."
  provider = aws.dns
}
