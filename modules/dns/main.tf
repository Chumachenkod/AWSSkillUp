resource "aws_acm_certificate" "tls_certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_route53_zone" "domain_zone" {
  name = var.domain_name
}

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.tls_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.domain_zone.zone_id
}

data "aws_route53_zone" "parent_zone" {
  name        = "skillup.nixsolutions.pp.ua"
  private_zone = "false"

}

resource "aws_route53_record" "ns_record_in_parent_zone" {
  allow_overwrite = true
  name            = var.domain_name
  records         = aws_route53_zone.domain_zone.name_servers
  ttl             = 60
  type            = "NS"
  zone_id         = data.aws_route53_zone.parent_zone.zone_id
}

resource "aws_route53_record" "load_balancer_record" {
  zone_id = aws_route53_zone.domain_zone.zone_id
  name    = aws_route53_zone.domain_zone.name
  type    = "A"

  alias {
    name                   = var.dns_name
    zone_id                = var.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.tls_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
}
