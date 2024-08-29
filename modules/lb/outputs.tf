output "blue_tag_arn" {
  value = aws_lb_target_group.blue.arn
}

output "green_tag_arn" {
  value = aws_lb_target_group.green.arn
}

output "lb_name" {
  value = aws_lb.this.name
}