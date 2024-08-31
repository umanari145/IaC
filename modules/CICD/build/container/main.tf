resource "aws_iam_role_policy_attachment" "codebuild_ecr_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# CodeBuildプロジェクトを作成
resource "aws_codebuild_project" "my_project" {
  name          = "${var.project_pre}-CodeBuildProject"
  description   = "Sample CodeBuild project"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 20

  artifacts {
    type      = "No artifacts"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
    privileged_mode = true
    environment_variable {
      name  = "ENV"
      value = "dev"
    }
  }

  source {
    type      = "GITHUB"
    location  = "https://github.com/umanari145/phptips"
    buildspec = "buildspec.yaml"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
      group_name = "${var.project_pre}/codebuild-project-logs"
      stream_name = "codebuild-log-stream"
    }
  }
}
