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
| [aws_default_route_table.route_table](https://registry.terraform.io/providers/hashicorp/aws/5.13.1/docs/resources/default_route_table) | resource |
| [aws_default_security_group.default_sg](https://registry.terraform.io/providers/hashicorp/aws/5.13.1/docs/resources/default_security_group) | resource |
| [aws_internet_gateway.gw](https://registry.terraform.io/providers/hashicorp/aws/5.13.1/docs/resources/internet_gateway) | resource |
| [aws_route.internet_route](https://registry.terraform.io/providers/hashicorp/aws/5.13.1/docs/resources/route) | resource |
| [aws_security_group.vpc_sg](https://registry.terraform.io/providers/hashicorp/aws/5.13.1/docs/resources/security_group) | resource |
| [aws_subnet.subnet](https://registry.terraform.io/providers/hashicorp/aws/5.13.1/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/5.13.1/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ipv4_cidr_config"></a> [ipv4\_cidr\_config](#input\_ipv4\_cidr\_config) | ipv4 range | <pre>map(object(<br>    {<br>      cidr = string<br>      az   = string<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | name to create resources | `string` | n/a | yes |
| <a name="input_security_group_config"></a> [security\_group\_config](#input\_security\_group\_config) | configration to create security groups | <pre>map(object(<br>    {<br>      port     = string<br>      protocol = string<br>      ipv4     = list(string)<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | vpc ip range | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_security_group"></a> [default\_security\_group](#output\_default\_security\_group) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | n/a |
| <a name="output_vpc_security_group"></a> [vpc\_security\_group](#output\_vpc\_security\_group) | n/a |
