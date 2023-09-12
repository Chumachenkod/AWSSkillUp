resource "aws_lb" "alb" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnets
}

resource "aws_lb_target_group" "target-group" {
  name        = "${var.name}-target-group"
  port        = local.container_port
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

resource "aws_route53_record" "ns_record_in_parent_zone" {
  allow_overwrite = true
  name            = local.domain_name
  records         = aws_route53_zone.domain_zone.name_servers
  ttl             = 60
  type            = "NS"
  zone_id         = local.parent_dns_zone
}

resource "aws_route53_record" "load_balancer_record" {
  zone_id = aws_route53_zone.domain_zone.zone_id
  name    = aws_route53_zone.domain_zone.name
  type    = "A"

  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.tls_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = local.listener_port
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = aws_acm_certificate_validation.validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}-skillup-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

data "aws_iam_policy_document" "ecs_task_policy_document" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.name}-ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_policy_document.json
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = local.ecs_task_execution_policy_arn
}

module "container_definition" {
  source          = "cloudposse/ecs-container-definition/aws"
  container_name  = local.container_name
  container_image = local.container_image
  port_mappings   = [
    {
      "containerPort" : tostring(local.container_port)
      "hostPort" : tostring(local.container_port)
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
      "awslogs-group"         = "${var.name}-log-group",
      "awslogs-region"        = data.aws_region.current.name,
      "awslogs-stream-prefix" = "streaming"
    }
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.name}docker_flask_task_definition"
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.ram-memory
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = module.container_definition.json_map_encoded_list
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
}


resource "aws_ecs_service" "ecs_service" {
  name                   = "${var.name}docker_flask_service"
  launch_type            = "FARGATE"
  cluster                = aws_ecs_cluster.ecs_cluster.id
  desired_count          = var.desired_tasks_count
  task_definition        = aws_ecs_task_definition.task_definition.arn
  enable_execute_command = true

  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target-group.arn
    container_name   = local.container_name
    container_port   = local.container_port
  }
}

provider aws {
  profile = "SkillUp"
  region  = "us-east-1"
}

locals {
  container_port                = 80
  container_image               = "253650698585.dkr.ecr.us-east-1.amazonaws.com/chumachenko_skillup_17task:${var.AppVersion}"
  container_name                = "${var.name}-flask-application-container"
  domain_name                   = "chumachenko.dmytro.skillup.nixsolutions.pp.ua"
  listener_port                 = 443
  ecs_task_execution_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  parent_dns_zone               = "Z04704221CYST9YCK9YKE"
}
