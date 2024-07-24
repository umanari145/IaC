resource "aws_sns_topic" "this" {
  name = var.topic_name

  // CloudWatch Logsの設定
  cloudwatch_logs_role_arn = aws_iam_role.sns_logging_role.arn
  cloudwatch_logs_enabled  = true
}

resource "aws_cloudwatch_log_group" "sns_delivery" {
  name = "/aws/sns/${var.topic_name}"
  retention_in_days = 30
}

resource "aws_iam_role" "sns_logging_role" {
  name = "${var.topic_name}-sns-logging-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
      "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
          "Service": "sns.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "sns_logging_policy" {
  name   = "${var.topic_name}-sns-logging-policy"
  role   = aws_iam_role.sns_logging_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        "Resource": [
          aws_cloudwatch_log_group.sns_delivery.arn,
          "${aws_cloudwatch_log_group.sns_delivery.arn}:*"
        ]
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.email_address
}

output "topic_arn" {
  value = aws_sns_topic.this.arn
}
