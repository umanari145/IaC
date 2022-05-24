#----------------------------------------
# ECRの作成
#----------------------------------------
resource "aws_ecr_repository" "ecr-nginx" {
  name               = "nginx-ecr-repository"
  tags = {
    Name = "nginx-ecr"
  }
}