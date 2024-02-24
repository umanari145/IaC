#----------------------------------------
# ECRリポジトリのリスト(複数のリポジトリ)
#----------------------------------------
locals {
  repositories = ["nginx-repository", "php-fpm-repository"]
}

#----------------------------------------
# ECRの作成
#----------------------------------------
resource "aws_ecr_repository" "nginx-repository" {
  name     = "nginx-repository"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "webrepo"
  }
}

resource "aws_ecr_repository" "php-fpm-repository" {
  name     = "php-fpm-repository"

  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Name = "webrepo"
  }
}

#----------------------------------------
# ECRのライフサイクル(直近3つまで)
#----------------------------------------
resource "aws_ecr_lifecycle_policy" "nginx-policy" {
  repository = aws_ecr_repository.nginx-repository.name
  policy = file("${path.module}/aws_ecr_lifecycle_policy.json")
}

resource "aws_ecr_lifecycle_policy" "php-fpm-policy" {
  repository = aws_ecr_repository.php-fpm-repository.name
  policy = file("${path.module}/aws_ecr_lifecycle_policy.json")
}

#----------------------------------------
# rulePriority: ルールの優先順位を指定します。ここでは 1 が指定されており、複数のルールがある場合はこの値が小さいほど優先して適用されます。
# description: ルールの説明です。ここでは "Keep last 3 images" として、意図を明確にしています。
# selection: このルールが適用されるイメージの選択条件を指定します。
# tagStatus: "any" と指定されており、タグの状態にかかわらずすべてのイメージにルールを適用します。
# countType: "imageCountMoreThan" と指定されており、指定された数を超えるイメージに対してアクションを適用することを意味します。
# countNumber: この数値に 3 を指定することで、リポジトリ内のイメージが3つより多い場合にのみルールが適用されます。
# action: 適用するアクションを指定します。
# type: "expire" と指定されており、条件に合致するイメージをリポジトリから自動的に削除（期限切れとする）ことを意味します。
#----------------------------------------