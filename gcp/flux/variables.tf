variable "flux_settings" {
  description = "Customize or override flux helm chart values"
  type        = map(string)
  default     = {}
}

variable "flux_helm_operator_settings" {
  description = "Customize or override flux helm operator chart values"
  type        = map(string)
  default     = {}
}

variable "flux_git_url" {
  default = ""
}

variable "gke_cluster" {}

variable "location" {}

variable "namespace" { default = "default" }
