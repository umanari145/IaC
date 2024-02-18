# 許可IPなど(一般的には自分のIP)
locals {
  admit_ip  = "113.149.17.185"
  azs = ["us-east-1a","us-east-1b"]
  cidr_block = [
    "10.0.1.0/24", "10.0.2.0/24"
  ]
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
# プライベートサブネットの作成(EC2)
#----------------------------------------
resource "aws_subnet" "webap_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "${local.cidr_block[count.index]}"
  availability_zone       = "${local.azs[count.index]}"
  tags = {
    Name = "${format("webAPsubnet-%02d", count.index + 1)}"
  }
}


#----------------------------------------
# サブネットとルートテーブルを紐づけ(通常のwebApのサブネット)
#----------------------------------------
resource "aws_route_table_association" "sample_web_rt_assoc" {
  count          = 2
  subnet_id      = "${element(aws_subnet.webap_subnet.*.id, count.index)}"
  route_table_id = aws_route_table.sample_rtb.id
}
#----------------------------------------
# セキュリティグループの作成
#----------------------------------------
resource "aws_security_group" "elb-sg" {
  name   = "elb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${local.admit_ip}/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${local.admit_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_server_sg" {
  name        = "web_server"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb-sg.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.elb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}