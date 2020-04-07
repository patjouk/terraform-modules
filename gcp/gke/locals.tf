locals {
  reloader_defaults = {
    "reloader.deployment.image.tag" = "v0.0.58"
  }
  reloader_settings = merge(local.reloader_defaults, var.reloader_settings)

  flux_helm_operator_defaults = {
    "helm.versions"      = "v3"
    "git.ssh.secretName" = "flux-git-deploy"
  }
  flux_helm_operator_settings = merge(local.flux_helm_operator_defaults, var.flux_helm_operator_settings)

  flux_defaults = {
    "git.ciSkip" = "true"
  }
  flux_settings = merge(local.flux_defaults, var.flux_settings)
}
