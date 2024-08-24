output "vpc_id" {
  value = aws_vpc.this.id
}

output "security_group_id" {
  value = aws_security_group.this.id
}

output "subnet_ids" {
  # 配列はこのように定義
  value = aws_subnet.this[*].id
}