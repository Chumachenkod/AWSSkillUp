resource "aws_lb" "alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-0fbec97fb10042b5d", "subnet-097c08f6ff5fdd36e"]

  enable_deletion_protection = true

}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = "vpc-02643980e80e1c78b"
  health_check {
    matcher = "200,301,302"
    path    = "/"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "white-hart"

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
  container_name  = "test-container"
  container_image = "253650698585.dkr.ecr.eu-west-1.amazonaws.com/chumachenko_skillup_17task:${var.AppVersion}"
  port_mappings   = [
    {
      "containerPort" : "8000"
      "hostPort" : "80"
    }
  ]
  environment = [
    {
      "name"  = "version"
      "value" = var.AppVersion
    }
  ]
}

resource "aws_ecs_task_definition" "FlaskApp" {
  family                   = "FlaskApp"
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = module.container_definition.json_map_encoded_list
}


resource "aws_ecs_service" "FlaskApp" {
  name            = "FlaskApp"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  desired_count   = 2
  task_definition = aws_ecs_task_definition.FlaskApp.arn

  network_configuration {
    subnets = ["subnet-0fbec97fb10042b5d", "subnet-097c08f6ff5fdd36e"]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "test-container"
    container_port   = 8000
  }
}

provider aws {
  profile = "SkillUp"
  region  = "us-east-1"
}
