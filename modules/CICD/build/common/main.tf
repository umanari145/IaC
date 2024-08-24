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

resource "aws_iam_role_policy_attachment" "attach_cloudwatch_logs_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}
# IAMポリシーをロールにアタッチ
resource "aws_iam_role_policy_attachment" "codebuild_role_policy" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
}
