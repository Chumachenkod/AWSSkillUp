resource "aws_vpc" "vpc" {
  tags = {
    Name = "${var.name}-skillup"
  }
  cidr_block = var.vpc_cidr
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-skillup"
  }
}
resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_route" "internet_route" {
  route_table_id         = aws_default_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_security_group" "vpc_sg" {
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = var.security_group_config
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["protocol"]
      cidr_blocks = ingress.value["ipv4"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name}-skillup"
  }
}

resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.name}-skillup-vpc"
  }
}

resource "aws_subnet" "subnet" {
  for_each   = var.ipv4_cidr_config
  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value[
  "cidr"
  ]
  availability_zone = each.value["az"]

  tags = {
    Name = "${var.name}-skillup"
  }
}
