module "VPC" {
  source = "../modules/vpc"
  project_pre = var.project_pre
}

module "LB" {
  source = "../modules/lb"
  project_pre = var.project_pre
  vpc_id = module.VPC.vpc_id
  security_group_id = module.VPC.security_group_id
  subnet_ids = module.VPC.subnet_ids
}

module "ECS" {
  source = "../modules/ecs"
  project_pre = var.project_pre
  ecr_uri = var.ecr_uri
  blue_tag_arn = module.LB.blue_tag_arn
  green_tag_arn = module.LB.green_tag_arn
  security_group_id = module.VPC.security_group_id
  subnet_ids = module.VPC.subnet_ids
}

module "CodeBuild" {
  source = "../modules/CICD/build"
  project_pre = var.project_pre
  account_id = var.account_id
  aws_region = var.aws_region
  repo = var.repo
}

module "CodeDeploy" {
  source = "../modules/CICD/deploy/container"
  project_pre = var.project_pre
  ecs_cluster_name = module.ECS.ecs_cluster_name
  ecs_service_name = module.ECS.ecs_service_name
  lb_listener_arn = module.LB.lb_listener_arn
  blue_tag_name = module.LB.blue_tag_name
  green_tag_name = module.LB.green_tag_name
}