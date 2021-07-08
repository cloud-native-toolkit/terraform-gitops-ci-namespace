# Dev Namespace Gitops module

Module to provision a namespace for development in gitops.

## Software dependencies

The module depends on the following software components:

### Command-line tools

- terraform - v13
- kubectl

### Terraform providers

-None

## Module dependencies

This module makes use of the output from other modules:

- GitOps repo - github.com/cloud-native-toolkit/terraform-tools-gitops.git
- Namespace - github.com/cloud-native-toolkit/terraform-gitops-namespace.git

## Example usage

```hcl-terraform
module "gitops_dev_namespace" {
  source = "github.com/cloud-native-toolkit/terraform-gitops-dev-namespace"

  config_repo = module.gitops.config_repo
  config_token = module.gitops.config_token
  config_paths = module.gitops.config_paths
  config_projects = module.gitops.config_projects
  application_repo = module.gitops.application_repo
  application_token = module.gitops.application_token
  application_paths = module.gitops.application_paths
  namespace = module.gitops_namespace.name
}
```

