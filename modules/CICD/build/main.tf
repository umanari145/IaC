
# S3バケットを作成（CodeBuildのアーティファクトを保存）
resource "aws_s3_bucket" "codebuild_bucket" {
  bucket = "${var.project_pre}-my-codebuild-bucket"
}

resource "aws_s3_object" "artifacts" {
  bucket = aws_s3_bucket.codebuild_bucket.id
  key    = "artifacts/"
}

resource "aws_iam_policy" "codebuild_s3_policy" {
  name        = "${var.project_pre}-CodeBuildS3AccessPolicy"
  description = "Policy to allow CodeBuild to upload artifacts to S3"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.project_pre}-my-codebuild-bucket",            # バケット自体へのアクセス
          "arn:aws:s3:::${var.project_pre}-my-codebuild-bucket/*"           # バケット内のオブジェクトへのアクセス
        ]
      }
    ]
  })
}


resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "${var.project_pre}-CloudWatchLogsPolicy"
  description = "Allows access to specific CloudWatch Logs resources for CodeBuild"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "*",
        ]
      }
    ]
  })
}

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

resource "aws_iam_role_policy_attachment" "codebuild_s3_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "codebuild_role_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}

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
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:6.0"
    type         = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.account_id
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/${var.repo}.git"
    buildspec       = "buildspec.yml"
    git_clone_depth = 1
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
      group_name = "${var.project_pre}/codebuild-project-logs"
      stream_name = "codebuild-log-stream"
    }
  }
}

