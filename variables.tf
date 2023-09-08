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
