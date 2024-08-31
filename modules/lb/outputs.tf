output "blue_tag_arn" {
  value = aws_lb_target_group.blue.arn
}

output "green_tag_arn" {
  value = aws_lb_target_group.green.arn
}

output "blue_tag_name" {
  value = aws_lb_target_group.blue.name
}

output "green_tag_name" {
  value = aws_lb_target_group.green.name
}

output "lb_listener_arn" {
  value = aws_lb_listener.this.arn
}

output "lb_name" {
  value = aws_lb.this.name
}