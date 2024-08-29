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
  ecr_uri = "public.ecr.aws/docker/library/httpd"
  blue_tag_arn = module.LB.blue_tag_arn
  green_tag_arn = module.LB.green_tag_arn
  security_group_id = module.VPC.security_group_id
  subnet_ids = module.VPC.subnet_ids
}

# ダミー的なProject(public.ecr.aws/docker/library/httpd)をつかっているのでbuildをskip
#module "CICD-Build-Common" {
#  source = "../modules/CICD/build/common"
#  project_pre = var.project_pre
#}

#module "CICD-Build-Condition" {
#  source = "../modules/CICD/deploy/container"
#  project_pre = var.project_pre
#  ecs_cluster_name = module.ECS.ecs_cluster_name
#  ecs_service_name = module.ECS.ecs_service_name
#  blue_tag_arn = module.LB.blue_tag_arn
#  green_tag_arn = module.LB.green_tag_arn
#  lb_name = module.LB.lb_name
#}