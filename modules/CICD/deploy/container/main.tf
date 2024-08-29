# CodeDeploy用のIAMロールの作成
resource "aws_iam_role" "codedeploy_role" {
  name = "${var.project_pre}-CodeDeployServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAMポリシーをCodeDeployロールにアタッチ
resource "aws_iam_role_policy_attachment" "codedeploy_policy_attachment" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

# CodeDeployアプリケーションの作成
resource "aws_codedeploy_app" "app_name" {
  name = "${var.project_pre}-codedeploy-app"
  compute_platform = "ECS"
}
# CodeDeployアプリケーショングループの作成
resource "aws_codedeploy_deployment_group" "ecs_deployment_group" {
  deployment_group_name  = "${var.project_pre}-deployment-group"
  app_name               = aws_codedeploy_app.app_name.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 180
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    prod_traffic_route {
      listener_arns = [
        var.aws_lb_listener.arn
      ]
    }
    
    target_group {
      name = aws_lb_target_group.blue.name
    } 

    target_group {
      name = aws_lb_target_group.green.name
    }
  }
}
