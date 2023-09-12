variable "AppVersion" {
  type = string
  default = "12.0"
}

variable "vpc_id" {
  type = string
  default = "vpc-02643980e80e1c78b"
}

variable "subnets" {
  type = list(string)
  default = ["subnet-0fbec97fb10042b5d", "subnet-097c08f6ff5fdd36e"]
}

variable "name" {
  type = string
  default = "chumachenkod"
}

variable "desired_tasks_count" {
  type = number
  default = 2
}

variable "cpu" {
  type = string
  default = "512"
}

variable "ram-memory" {
  type = string
  default = "1024"
}

variable "ssl_policy" {
  type = string
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}