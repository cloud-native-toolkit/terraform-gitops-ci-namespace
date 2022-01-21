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

  triggers = {
    name = local.name
    namespace = var.namespace
    yaml_dir = local.yaml_dir
    server_name = var.server_name
    layer = local.layer
    git_credentials = yamlencode(var.git_credentials)
    gitops_config   = yamlencode(var.gitops_config)
    bin_dir = local.bin_dir
  }

  provisioner "local-exec" {
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}'"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${self.triggers.bin_dir}/igc gitops-module '${self.triggers.name}' -n '${self.triggers.namespace}' --delete --contentDir '${self.triggers.yaml_dir}' --serverName '${self.triggers.server_name}' -l '${self.triggers.layer}' --debug"

    environment = {
      GIT_CREDENTIALS = nonsensitive(self.triggers.git_credentials)
      GITOPS_CONFIG   = self.triggers.gitops_config
    }
  }
}


module "pipeline_privileged_scc" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-sccs.git?ref=v1.1.6"

  gitops_config = var.gitops_config
  git_credentials = var.git_credentials
  namespace = var.namespace
  service_account = "pipeline"
  sccs = var.provision ? ["privileged"] : []
  server_name = var.server_name
}
