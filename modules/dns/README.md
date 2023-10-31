## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.6.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | = 5.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | = 5.13.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.tls_certificate](https://registry.terraform.io/providers/hashicorp/aws/5.13.1/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.validation](https://registry.terraform.io/providers/hashicorp/aws/5.13.1/docs/resources/acm_certificate_validation) | resource |
| [aws_route53_record.certificate_validation](https://registry.terraform.io/providers/hashicorp/aws/5.13.1/docs/resources/route53_record) | resource |
| [aws_route53_record.load_balancer_record](https://registry.terraform.io/providers/hashicorp/aws/5.13.1/docs/resources/route53_record) | resource |
| [aws_route53_record.ns_record_in_parent_zone](https://registry.terraform.io/providers/hashicorp/aws/5.13.1/docs/resources/route53_record) | resource |
| [aws_route53_zone.domain_zone](https://registry.terraform.io/providers/hashicorp/aws/5.13.1/docs/resources/route53_zone) | resource |
| [aws_route53_zone.parent_zone](https://registry.terraform.io/providers/hashicorp/aws/5.13.1/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | dns name to create alias | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | domain name to create new domain | `string` | n/a | yes |
| <a name="input_parent_zone_name"></a> [parent\_zone\_name](#input\_parent\_zone\_name) | the name of the parent zone to add NS records of our domain zone | `string` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | id zone which contain load balancer | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | TLS validate certificate ARN |
| <a name="output_parent_dns"></a> [parent\_dns](#output\_parent\_dns) | n/a |
