locals {
  bin_dir = "${path.cwd}/bin"
  layer = "infrastructure"
  yaml_dir = "${path.cwd}/.tmp/dev-namespace/${var.namespace}"
  application_branch = "main"
  application_base_path = var.gitops_config.applications.payload.path
}

resource null_resource setup_binaries {
  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-binaries.sh"

    environment = {
      BIN_DIR = local.bin_dir
    }
  }
}

resource null_resource create_yaml {
  depends_on = [null_resource.setup_binaries]

  provisioner "local-exec" {
    command = "${path.module}/scripts/create-yaml.sh '${local.yaml_dir}' '${local.application_base_path}' '${local.application_branch}'"
  }
}

resource null_resource setup_gitops {
  depends_on = [null_resource.create_yaml]

  provisioner "local-exec" {
    command = "PATH=${local.bin_dir}:$${PATH} igc gitops-module 'ci-config' -n '${var.namespace}' --contentDir '${local.yaml_dir}' --serverName '${var.serverName}' -l '${local.layer}'"

    environment = {
      GIT_CREDENTIALS = yamlencode(var.git_credentials)
      GITOPS_CONFIG   = yamlencode(var.gitops_config)
    }
  }
}
