module "gitops_dev_namespace" {
  source = "./module"

  gitops_config = module.gitops.gitops_config
  git_credentials = module.gitops.git_credentials
  namespace = var.namespace
  server_name = module.gitops.server_name
}
