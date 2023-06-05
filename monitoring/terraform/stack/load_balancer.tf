resource "aws_alb" "alb" {
  # This name can only contain alphanumerics and hyphens
  name = "${replace(var.namespace, "_", "-")}-grafana"

  subnets = var.public_subnets

  security_groups = [
    aws_security_group.service_lb_security_group.id,
    aws_security_group.external_lb_security_group.id,
  ]
}

resource "aws_alb_target_group" "grafana_ecs_service" {
  name = "monitoring-grafana"

  target_type = "ip"
  protocol    = "HTTP"
  port        = local.container_port
  vpc_id      = var.vpc_id

  health_check {
    protocol = "HTTP"
    path     = "/api/health"
    matcher  = "200"
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.alb.id
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = module.cert.arn

  default_action {
    target_group_arn = aws_alb_target_group.grafana_ecs_service.arn
    type             = "forward"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.alb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

module "cert" {
  source = "github.com/wellcomecollection/terraform-aws-acm-certificate?ref=v2.0.0"

  domain_name = var.domain
  zone_id     = data.aws_route53_zone.dotorg.id

  providers = {
    aws.dns = aws.dns
  }
}

data "aws_route53_zone" "dotorg" {
  provider = aws.dns
  name     = "wellcomecollection.org."
}
