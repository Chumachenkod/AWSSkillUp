output "target_group_arn" {
  value       = aws_lb_target_group.target-group.arn
  description = "Target Group ARN"
}

output "dns_name" {
  value = aws_lb.alb.dns_name
  description = "Load Balancer DNS name"
}

output "zone_id" {
  value = aws_lb.alb.zone_id
  description = "Load Balancer Zone id"
}