module "CICD-Build-Common" {
  source = "../modules/CICD/build/common"
  project_pre = var.project_pre
}

module "CICD-Build-Condition" {
  source = "../modules/CICD/build/artifacts"
  project_pre = var.project_pre
  codebuild_role_name = module.CICD-Build-Common.codebuild_role_name
  codebuild_role_arn = module.CICD-Build-Common.codebuild_role_arn
}