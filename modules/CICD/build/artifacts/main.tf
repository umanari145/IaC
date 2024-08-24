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

resource "aws_iam_role_policy_attachment" "codebuild_s3_policy_attachment" {
  role       = var.codebuild_role_name
  policy_arn = aws_iam_policy.codebuild_s3_policy.arn
}

# CodeBuildプロジェクトを作成
resource "aws_codebuild_project" "my_project" {
  name          = "${var.project_pre}-CodeBuildProject"
  description   = "Sample CodeBuild project"
  service_role  = var.codebuild_role_arn
  build_timeout = 20

  artifacts {
    type      = "S3"
    location  = aws_s3_bucket.codebuild_bucket.bucket
    packaging = "ZIP"
    name      = "output.zip"
    path      = "artifacts/"
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
