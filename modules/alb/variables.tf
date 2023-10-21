variable "certificate_arn" {
}
variable "vpc_id" {
}
variable "container_port" {
}
variable "listener_port" {
}
variable "name" {
}
variable "security_groups" {}
variable "subnets" {
  type = list(string)
}
variable "ssl_policy" {}
