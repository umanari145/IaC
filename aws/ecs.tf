#----------------------------------------
# クラスター
#----------------------------------------
resource "aws_ecs_cluster" "sample_ecs_cluster" {
  name = "sample_ecs_cluster"

  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT"
  ]

  tags = {
    Name = "sample_ecs_cluster"
  }
}