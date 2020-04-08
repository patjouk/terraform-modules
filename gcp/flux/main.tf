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
    "git.url"    = var.flux_git_url
  }
  flux_settings = merge(local.flux_defaults, var.flux_settings)
}

data "google_container_cluster" "cluster" {
  name     = var.gke_cluster
  location = var.gke_cluster_location
}

data "google_client_config" "current" {
}

provider "helm" {
  version = "~> 1"

  kubernetes {
    host                   = data.google_container_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)
    client_key             = base64decode(data.google_container_cluster.cluster.master_auth.0.client_key)
    client_certificate     = base64decode(data.google_container_cluster.cluster.master_auth.0.client_certificate)
    token                  = data.google_client_config.current.access_token
    load_config_file       = false
  }
}

data "helm_repository" "fluxcd" {
  name = "fluxcd"
  url  = "https://charts.fluxcd.io"
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

  depends_on = [var.gke_cluster]
}

resource "helm_release" "flux_helm_operator" {
  name       = "helm-operator"
  repository = data.helm_repository.fluxcd.metadata.0.name
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

  depends_on = [var.gke_cluster]
  skip_crds  = true
}

resource "helm_release" "fluxcd" {
  name       = "flux"
  repository = data.helm_repository.fluxcd.metadata.0.name
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
resource "kubernetes_namespace" "flux" {
  metadata {
    name = "fluxcd"
  }
}
