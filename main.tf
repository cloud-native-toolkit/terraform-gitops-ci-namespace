locals {
  layer = "infrastructure"
  layer_config = var.gitops_config[local.layer]
  application_branch = "main"
  config_namespace = "default"
  yaml_dir = "${path.cwd}/.tmp/dev-namespace/${var.namespace}"
  application_base_path = var.gitops_config.applications.payload.path
}

resource null_resource create_yaml {
  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${local.application_base_path}' '${local.application_branch}'"
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-gitops.sh 'namespace-${var.namespace}' '${local.yaml_dir}' 'namespace/${var.namespace}' '${local.application_branch}' '${var.namespace}'"

    environment = {
      GIT_CREDENTIALS = jsonencode(var.git_credentials)
      GITOPS_CONFIG = jsonencode(local.layer_config)
    }
  }
}
