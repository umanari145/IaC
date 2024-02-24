#----------------------------------------
# ECS_TASK用のIAMロール
#----------------------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution_sample"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )

  tags = {
    Name = "ecs-task-execution_sample"
  }
}

resource "aws_iam_policy" "ecs_logs_policy" {
  name        = "ecs-logs-policy"
  path        = "/"
  description = "Allows ECS tasks to create and manage their own CloudWatch log groups and streams"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "*"
      }
    ]
  })
}



#----------------------------------------
# ECS_TASK用のIAMポリシー
#----------------------------------------
data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#----------------------------------------
# ECS_TASK用のIAMロールにポリシーを付与
#----------------------------------------
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution.arn
}

resource "aws_iam_role_policy_attachment" "ecs_logs_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_logs_policy.arn
}