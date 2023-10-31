variable "certificate_arn" {
  description = "ssl certificate ARN"
  type        = string
}
variable "vpc_id" {
  description = "vpc id to create load balancer"
  type        = string
}
variable "container_port" {
  description = "container port to forward traffic"
  type        = string
}
variable "listener_port" {
  description = "listener port to receive incoming traffic"
  type        = string
}
variable "name" {
  description = "name to create resources"
  type        = string
}
variable "security_groups" {
  description = "security groups ids to set up listener"
  type        = list(string)
}
variable "subnets" {
  description = "subnets ids to create load balancer in them"
  type = list(string)
}
variable "ssl_policy" {
  description = "ssl secure policy to create load balancer"
  type        = string
}
