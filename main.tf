locals {
  bin_dir  = module.setup_clis.bin_dir
  layer = "infrastructure"
  yaml_dir = "${path.cwd}/.tmp/dev-namespace/${var.namespace}"
  application_repo = var.gitops_config.applications.payload.repo
  application_base_path = var.gitops_config.applications.payload.path
  application_branch = "main"
  name = "ci-config"
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

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]
  count = var.provision ? 1 : 0

  provisioner "local-exec" {
    command = "${local.bin_dir}/igc gitops-module '${local.name}' -n '${var.namespace}' --contentDir '${local.yaml_dir}' --serverName '${var.server_name}' -l '${local.layer}'"

    environment = {
      GIT_CREDENTIALS = yamlencode(nonsensitive(var.git_credentials))
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}

module "pipeline_privileged_scc" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-sccs.git?ref=debug"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = var.namespace
  service_account = "pipeline"
  sccs = var.provision ? ["privileged"] : []
  server_name = var.server_name
}
