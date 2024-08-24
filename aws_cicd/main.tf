module "CICD-Build" {
  source = "../modules/CICD/build"
  project_pre = var.project_pre
}