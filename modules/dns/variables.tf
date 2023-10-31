variable "dns_name" {
  description = "dns name to create alias"
  type = string
}
variable "zone_id" {
  description = "id zone which contain load balancer"
  type = string
}
variable "domain_name" {
  description = "domain name to create new domain"
  type = string
}
variable "parent_zone_name" {
  description = "the name of the parent zone to add NS records of our domain zone"
  type = string
}