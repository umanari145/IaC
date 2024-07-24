module "sns_topic" {
  source            = "../modules/sns_topic"
  topic_name        = "example-topic"
  email_address     = var.email_address
  log_retention_days = var.log_retention_days
}

output "topic_arn" {
  value = module.sns_topic.topic_arn
}

module "lambda" {
  source                = "./modules/lambda"
  function_name         = "example_lambda"
  handler               = "index.handler"
  runtime               = "python"
  lambda_zip_path       = var.lambda_zip_path
  sns_topic_arn         = module.sns_topic.topic_arn
  environment_variables = {
    SNS_TOPIC_ARN = module.sns_topic.topic_arn
  }
}

output "lambda_arn" {
  value = module.lambda.lambda_arn
}