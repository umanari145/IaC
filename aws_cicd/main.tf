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
  lb_tag_arn = module.LB.lb_tag_arn
  security_group_id = module.VPC.security_group_id
  subnet_ids = module.VPC.subnet_ids
}

#module "CICD-Build-Common" {
#  source = "../modules/CICD/build/common"
#  project_pre = var.project_pre
#}
#
#module "CICD-Build-Condition" {
#  source = "../modules/CICD/build/container"
#  project_pre = var.project_pre
#  codebuild_role_name = module.CICD-Build-Common.codebuild_role_name
#  codebuild_role_arn = module.CICD-Build-Common.codebuild_role_arn
#}