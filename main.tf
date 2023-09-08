resource "aws_lb" "chumachenkod-alb" {
  name               = "chumachenkod-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnets
}

resource "aws_lb_target_group" "chumachenkod-target-group" {
  name        = "chumachenkod-target-group"
  port        = local.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    matcher = "200"
    path    = "/"
  }
}

resource "aws_acm_certificate" "tls_certificate" {
  domain_name       = local.domain_name
  validation_method = "DNS"
}

resource "aws_route53_zone" "domain_zone" {
  name = local.domain_name
}

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.tls_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.domain_zone.zone_id
}

resource "aws_route53_record" "load_balancer_record" {
  zone_id = aws_route53_zone.domain_zone.zone_id
  name    = aws_route53_zone.domain_zone.name
  type    = "A"

  alias {
    name                   = aws_lb.chumachenkod-alb.dns_name
    zone_id                = aws_lb.chumachenkod-alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.tls_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
}

resource "aws_lb_listener" "chumachenkod-listener" {
  load_balancer_arn = aws_lb.chumachenkod-alb.arn
  port              = 443
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.tls_certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chumachenkod-target-group.arn
  }
}

resource "aws_ecs_cluster" "chumachenkod-ecs_cluster" {
  name = "chumachenkod-skillup-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "chumachenkod-ecsTaskExecutionRole"

  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

module "container_definition" {
  source          = "cloudposse/ecs-container-definition/aws"
  container_name  = local.container_name
  container_image = local.container_image
  port_mappings   = [
    {
      "containerPort" : tostring(local.port)
      "hostPort" : tostring(local.port)
      "protocol" : "HTTP"
    }
  ]
  environment = [
    {
      "name"  = "APPLICATION_VERSION"
      "value" = var.AppVersion
    }
  ]
  log_configuration = {
    "logDriver" = "awslogs",
    "options"   = {
      "awslogs-group"         = "chumachenkod-log-group",
      "awslogs-region"        = "us-east-1",
      "awslogs-stream-prefix" = "streaming"
    }
  }
}

resource "aws_ecs_task_definition" "FlaskApp" {
  family                   = "FlaskApp"
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = module.container_definition.json_map_encoded_list
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
}


resource "aws_ecs_service" "FlaskApp" {
  name                   = "FlaskApp"
  launch_type            = "FARGATE"
  cluster                = aws_ecs_cluster.chumachenkod-ecs_cluster.id
  desired_count          = 2
  task_definition        = aws_ecs_task_definition.FlaskApp.arn
  enable_execute_command = true

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.chumachenkod-target-group.arn
    container_name   = local.container_name
    container_port   = local.port
  }
}

provider aws {
  profile = "SkillUp"
  region  = "us-east-1"
}

locals {
  port            = 80
  container_image = "253650698585.dkr.ecr.us-east-1.amazonaws.com/chumachenko_skillup_17task:${var.AppVersion}"
  container_name  = "chumachenkod-flask-application-container"
  domain_name     = "chumachenko.dmytro.skillup.nixsolutions.pp.ua"
}