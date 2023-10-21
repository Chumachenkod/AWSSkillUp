module "network" {
  source           = "./modules/network"
  name             = var.name
  vpc_cidr         = var.vpc_cidr
  ipv4_cidr_config = {
    first = {
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
    }
    second = {
      cidr = "10.0.2.0/24"
      az   = "us-east-1b"
    }
  }

  security_group_config = {
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

module "load_balancer" {
  source          = "./modules/alb"
  certificate_arn = module.dns.certificate_arn
  container_port  = local.container_port
  listener_port   = local.listener_port
  name            = var.name
  subnets         = module.network.subnets
  vpc_id          = module.network.vpc
  security_groups = [module.network.default_security_group, module.network.vpc_security_group]
  ssl_policy      = var.ssl_policy
}

module "dns" {
  source      = "./modules/dns"
  dns_name    = module.load_balancer.dns_name
  zone_id     = module.load_balancer.zone_id
  domain_name = "${var.domain_name}.skillup.nixsolutions.pp.ua"
}


module "container_definition" {
  source          = "cloudposse/ecs-container-definition/aws"
  version = "0.60.0"
  container_name  = local.container_name
  container_image = "${data.aws_ecr_repository.repository.repository_url}:${var.AppVersion}"
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

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.name}-ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_policy_document.json
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = local.ecs_task_execution_policy_arn
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name}-skillup-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
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
    subnets          = module.network.subnets
  }

  load_balancer {
    target_group_arn = module.load_balancer.target_group_arn
    container_name   = local.container_name
    container_port   = local.container_port
  }
  depends_on = [module.load_balancer]
}
