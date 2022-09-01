locals {
  bin_dir  = module.setup_clis.bin_dir
  layer = "infrastructure"
  yaml_dir = "${path.cwd}/.tmp/dev-namespace/${var.namespace}"
  application_repo = var.gitops_config.applications.payload.repo
  application_base_path = var.gitops_config.applications.payload.path
  application_branch = "main"
  name = "ci-config"
  type = "base"
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"
}

resource null_resource create_yaml {
  count = var.provision ? 1 : 0

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${local.application_repo}' '${local.application_base_path}' '${local.application_branch}'"
  }
}

resource gitops_module module {
  depends_on = [null_resource.create_yaml]
  count = var.provision ? 1 : 0

  name = local.name
  namespace = var.namespace
  content_dir = local.yaml_dir
  server_name = var.server_name
  layer = local.layer
  type = local.type
  config = yamlencode(var.gitops_config)
  credentials = yamlencode(var.git_credentials)
}

module "pipeline_privileged_scc" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-sccs.git?ref=v1.4.1"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = var.namespace
  service_account = "pipeline"
  sccs = var.provision ? ["privileged"] : []
  server_name = var.server_name
}
