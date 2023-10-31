variable "name" {
  description = "name to create resources"
  type        = string
}
variable "security_group_config" {
  description = "configration to create security groups"
  type = map(object(
    {
      port     = string
      protocol = string
      ipv4     = list(string)
    }
  ))
}
variable "vpc_cidr" {
  description = "vpc ip range"
  type        = string
}
variable "ipv4_cidr_config" {
  description = "ipv4 range"
  type = map(object(
    {
      cidr = string
      az   = string
    }
  ))
}