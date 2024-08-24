locals {
  azs = ["us-east-1a","us-east-1b"]
  cidr_block = [
    "10.0.1.0/24", "10.0.2.0/24"
  ]
}

resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  tags = {
    Name = "${var.project_pre}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id
    tags = {
        Name = "${var.project_pre}-igw"
    }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "${var.project_pre}-rtb"
  }
}


resource "aws_subnet" "this" {
  count                   = 2
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "${local.cidr_block[count.index]}"
  availability_zone       = "${local.azs[count.index]}"
  tags = {
    Name = "${format("%s-sn-%02d", var.project_pre, count.index + 1)}"
  }
}

resource "aws_route_table_association" "this" {
  count          = 2
  subnet_id      = "${element(aws_subnet.this.*.id, count.index)}"
  route_table_id = aws_route_table.this.id
}

resource "aws_security_group" "this" {
  name   = "${var.project_pre}-sg"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}