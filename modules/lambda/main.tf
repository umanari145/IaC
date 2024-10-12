resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}_execution_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_service_role_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_iam_role_policy" "lambda_exec_policy" {
  name   = "${var.function_name}_execution_policy"
  role   = aws_iam_role.lambda_exec.id

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
        "Resource": "arn:aws:logs:*:*:*"
      }
    ]
  })
}

data "archive_file" "terraform_sorce" {
  type        = "zip"
  source_dir  = "lambda/test/src"
  output_path = "lambda/test/src/test_terraform.zip"
}

# AWSへ作るlambda function
resource "aws_lambda_function" "lambda_func" {
  function_name    = ""
  filename         = data.archive_file.terraform_sorce.output_path
  source_code_hash = data.archive_file.terraform_sorce.output_base64sha256
  runtime          = "python3.12"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "terraform.handler"
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}
