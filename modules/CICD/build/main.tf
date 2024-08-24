# IAMロールを作成
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_pre}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

# S3バケットを作成（CodeBuildのアーティファクトを保存）
resource "aws_s3_bucket" "codebuild_bucket" {
  bucket = "${var.project_pre}-my-codebuild-bucket"
}

# IAMポリシーをロールにアタッチ
resource "aws_iam_role_policy_attachment" "codebuild_role_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

# CodeBuildプロジェクトを作成
resource "aws_codebuild_project" "my_project" {
  name          = "${var.project_pre}-CodeBuildProject"
  description   = "Sample CodeBuild project"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 20

  artifacts {
    type = "S3"
    location = aws_s3_bucket.codebuild_bucket.bucket
    packaging = "ZIP"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
    environment_variable {
      name  = "ENV"
      value = "dev"
    }
  }

  source {
    type      = "GITHUB"
    location  = "https://github.com/umanari145/phptips"
    buildspec = "buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
      group_name = "codebuild-project-logs"
      stream_name = "codebuild-log-stream"
    }
  }
}
