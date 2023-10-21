variable "name" {}
variable "security_group_config" {
  type = map(object(
    {
      port     = string
      protocol = string
      ipv4     = list(string)
    }
  ))
}
variable "vpc_cidr" {}
variable "ipv4_cidr_config" {
  type = map(object(
    {
      cidr = string
      az   = string
    }
  ))
}