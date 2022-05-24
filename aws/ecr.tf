#----------------------------------------
# ECRの作成
#----------------------------------------
resource "aws_ecr_repository" "ecr-nginx" {
  name               = "nginx-ecr-repository"
  tags = {
    Name = "nginx-ecr"
  }
}

#----------------------------------------
# ECRのライフサイクル(直近3つまで)
#----------------------------------------
resource "aws_ecr_lifecycle_policy" "nginx-policy" {
  repository = aws_ecr_repository.ecr-nginx.name
  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 3 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}