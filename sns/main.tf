module "sns_topic" {
  source            = "../modules/sns_topic"
  topic_name        = "example-topic"
  email_address     = var.email_address
  log_retention_days = var.log_retention_days
}

output "topic_arn" {
  value = module.sns_topic.topic_arn
}
