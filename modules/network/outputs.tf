output "subnets" {
  value = [for sub in aws_subnet.subnet : sub.id]
}

output "vpc" {
  value = aws_vpc.vpc.id
}
output "default_security_group" {
  value = aws_default_security_group.default_sg.id
}
output "vpc_security_group" {
  value = aws_security_group.vpc_sg.id
}
