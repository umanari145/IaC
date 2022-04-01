# 許可IPなど
locals {
  admit_ip  = "113.149.17.185"
}

#----------------------------------------
# VPCの作成(一番外側のVPC)
#----------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  tags = {
    Name = "total_out_vpc"
  }
}

#----------------------------------------
# インターネットゲートウェイの作成
#----------------------------------------
resource "aws_internet_gateway" "sample_gw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "main_vpc_gateway"
    }
}

#----------------------------------------
# ルートテーブルの作成
#----------------------------------------
resource "aws_route_table" "sample_rtb" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sample_gw.id
  }
  tags = {
    Name = "main_rtb"
  }
}

#----------------------------------------
# プライベートサブネットの作成
#----------------------------------------
resource "aws_subnet" "ec2_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  tags = {
    Name = "ec2_subnet"
  }
}

#----------------------------------------
# サブネットにルートテーブルを紐づけ
#----------------------------------------
resource "aws_route_table_association" "sample_rt_assoc" {
  subnet_id      = aws_subnet.ec2_subnet.id
  route_table_id = aws_route_table.sample_rtb.id
}

#----------------------------------------
# セキュリティグループの作成
#----------------------------------------
resource "aws_security_group" "web_server_sg" {
  name        = "web_server"
  vpc_id      = aws_vpc.main.id
}

# 80番ポート許可のインバウンドルール
resource "aws_security_group_rule" "inbound_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  # 特定IPのみ許可
  cidr_blocks = ["${local.admit_ip}/32"]

  # ここでweb_serverセキュリティグループに紐付け
  security_group_id = aws_security_group.web_server_sg.id
}

# 443番ポート許可のインバウンドルール
resource "aws_security_group_rule" "inbound_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["${local.admit_ip}/32"]

  # ここでweb_serverセキュリティグループに紐付け
  security_group_id = aws_security_group.web_server_sg.id
}

# 22番ポート許可のインバウンドルール
resource "aws_security_group_rule" "inbound_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${local.admit_ip}/32"]

  # ここでweb_serverセキュリティグループに紐付け
  security_group_id = aws_security_group.web_server_sg.id
}

# アウトバウンドルール(全開放)
resource "aws_security_group_rule" "out_all" {
  security_group_id = aws_security_group.web_server_sg.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}