data "aws_region" "current" {
  provider = aws
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

data "aws_ecr_repository" "repository" {
  name = "chumachenko_skillup_17task"
}
