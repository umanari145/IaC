#----------------------------------------
# クラスター
#----------------------------------------
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "ecs-sample-cluster"

  tags = {
    Name = "sample_ecs_cluster"
  }
}

#----------------------------------------
# タスク
#----------------------------------------
resource "aws_ecs_task_definition" "ecs-task" {
  family                   = "backend_task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name             = "ecs-task-nginx"
      image            = "399153948641.dkr.ecr.us-east-1.amazonaws.com/nginx-repository:latest"
      portMappings     = [{
        containerPort: 80,
        hostPort: 80,
        protocol: "tcp"
      }],
      dependsOn = [{
          containerName: "ecs-task-php-fpm"
          condition: "START"
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-region : "us-east-1",
          awslogs-group : "ecs-sample",
          awslogs-create-group: "true",
          awslogs-stream-prefix : "nginx"
        }
      }
    },
    {
      name             = "ecs-task-php-fpm"
      image            = "399153948641.dkr.ecr.us-east-1.amazonaws.com/php-fpm-repository:latest"
      logConfiguration = {
        logDriver = "awslogs"
        options   = {
          awslogs-region : "us-east-1",
          awslogs-group : "ecs-sample",
          awslogs-create-group: "true",
          awslogs-stream-prefix : "php-fpm"
        }
      }
    }
  ])
}
#----------------------------------------
# サービス
#----------------------------------------
resource "aws_ecs_service" "ecs-service" {
  name            = "ecs-sample-service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task.arn
  desired_count = 2
  launch_type   = "FARGATE"
  network_configuration {
    subnets = [
      aws_subnet.public1.id,
      aws_subnet.public2.id,
    ]
    security_groups = [
      aws_security_group.public.id
    ]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "ecs-task-nginx"
    container_port   = 80
  }
}
