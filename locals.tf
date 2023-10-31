locals {
  container_port                = 80
  container_name                = "${var.name}_flask_application_container"
  listener_port                 = 443
  ecs_task_execution_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
