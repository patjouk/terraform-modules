provider "helm" {
  version = "~> 1"

  kubernetes {
    host                   = google_container_cluster.primary.endpoint
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
    client_key             = base64decode(google_container_cluster.primary.master_auth.0.client_key)
    client_certificate     = base64decode(google_container_cluster.primary.master_auth.0.client_certificate)
    token                  = data.google_client_config.current.access_token
    load_config_file       = false
  }
}

data "helm_repository" "fluxcd" {
  count = var.enable_flux ? 1 : 0
  name  = "fluxcd"
  url   = "https://charts.fluxcd.io"
}

data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "reloader" {
  name       = "reloader"
  repository = data.helm_repository.stable.metadata.0.name
  chart      = "stable/reloader"
  namespace  = "kube-system"

  dynamic "set" {
    iterator = item
    for_each = local.reloader_settings

    content {
      name  = item.key
      value = item.value
    }
  }

  depends_on = [google_container_cluster.primary]
}

resource "helm_release" "flux_helm_operator" {
  count      = var.enable_flux ? 1 : 0
  name       = "helm-operator"
  repository = data.helm_repository.fluxcd.0.name
  chart      = "fluxcd/helm-operator"
  namespace  = "fluxcd"

  dynamic "set" {
    iterator = item
    for_each = local.flux_helm_operator_settings

    content {
      name  = item.key
      value = item.value
    }
  }

  depends_on = [google_container_cluster.primary]
}

resource "helm_release" "fluxcd" {
  count      = var.enable_flux ? 1 : 0
  name       = "flux"
  repository = data.helm_repository.fluxcd.0.name
  chart      = "fluxcd/flux"
  namespace  = "fluxcd"

  dynamic "set" {
    iterator = item
    for_each = local.flux_settings

    content {
      name  = item.key
      value = item.value
    }
  }

}
