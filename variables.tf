variable "AppVersion" {
  type    = string
  default = "12.0"
}

variable "name" {
  type    = string
  default = "chumachenkod"
}

variable "desired_tasks_count" {
  type    = number
  default = 2
}

variable "cpu" {
  type    = string
  default = "512"
}

variable "ram-memory" {
  type    = string
  default = "1024"
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "domain_name" {
  type    = string
  default = "chumachenko.dmytro"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}