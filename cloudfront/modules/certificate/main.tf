resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  subject_alternative_names = var.subject_alternative_names

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  provider = aws.dns

  # This is based on an example from the Terraform docs
  # See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation#dns-validation-with-route-53
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]

  zone_id = var.zone_id

  ttl = var.ttl
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn = aws_acm_certificate.cert.arn

  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
