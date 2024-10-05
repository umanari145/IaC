resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${var.project_pre}-task"
  retention_in_days = 30
}

resource "aws_iam_role" "this" {

  name = "${var.project_pre}-ecsTaskRole"

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
    Name = "${var.project_pre}-ecsTaskRole"
  }
}

resource "aws_iam_policy" "this" {
  name        = "${var.project_pre}-ecsLogPolicy"
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
        "Resource":"${aws_cloudwatch_log_group.this.arn}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_attachement" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_log_attachement" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_ecs_cluster" "this" {
  name = "${var.project_pre}-ecs-cluster"

  tags = {
    Name = "${var.project_pre}-cluster"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "ecs-task-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.this.arn
  task_role_arn            = aws_iam_role.this.arn
  container_definitions    = jsonencode([
    {
      name             = "web-container"
      image            = "${var.ecr_uri}:latest"
      portMappings     = [{
        containerPort: 80,
        hostPort: 80,
        protocol: "tcp"
      }],
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-group         = "${aws_cloudwatch_log_group.this.name}"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "ecs-web-app"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name = "${var.project_pre}-ecs-srv"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count = 2
  launch_type   = "FARGATE"

  network_configuration {
    subnets = var.subnet_ids
    security_groups = [
      var.security_group_id
    ]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn =  var.blue_tag_arn
    container_name   = "web-container"
    container_port   = 80
  }

  # ecspressoを使う場合不要
  #deployment_controller {
  #  type = "CODE_DEPLOY"
  #}
}