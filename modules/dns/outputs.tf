output "certificate_arn" {
  value = aws_acm_certificate_validation.validation.certificate_arn
  description = "TLS validate certificate ARN"
}
output "parent_dns" {
  value = data.aws_route53_zone.parent_zone
}
