variable "AppVersion" {
  description = "application version to determine which version of the image to use"
  type    = string
  default = "12.0"
}

variable "name" {
  description = "name to create resources"
  type    = string
  default = "chumachenkod"
}

variable "desired_tasks_count" {
  description = "number of tasks to run"
  type    = number
  default = 2
}

variable "cpu" {
  description = "cpu to use in task"
  type    = string
  default = "512"
}

variable "ram_memory" {
  description = "ram memory to use in tasks"
  type    = string
  default = "1024"
}

variable "ssl_policy" {
  description = "ssl secure policy to create load balancer"
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "domain_name" {
  description = "domain name to create new domain"
  type    = string
  default = "chumachenko.dmytro.skillup.nixsolutions.pp.ua"
}

variable "vpc_cidr" {
  description = "vpc ip range"
  type    = string
  default = "10.0.0.0/16"
}

variable "ecr_repository" {
  description = "ecr repository to create containers"
  type    = string
  default = "chumachenko_skillup_17task"
}

variable "ipv4_cidr_config" {
  description = "ipv4 configuration to use in AZ"
  type = map(object({
    cidr = string,
    az   = string
  }))
  default = {
    first = {
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
    }
    second = {
      cidr = "10.0.2.0/24"
      az   = "us-east-1b"
    }
  }
}

variable "security_group_config" {
  description = "security group config to create"
  type = map(object({
    port     = string,
    protocol = string
    ipv4     = list(string)
  }))
  default = {
    http = {
      port     = "80"
      protocol = "tcp"
      ipv4     = ["77.253.252.244/32"]
    },
    https = {
      port     = "443"
      protocol = "tcp"
      ipv4     = ["77.253.252.244/32"]
    },
  }
}