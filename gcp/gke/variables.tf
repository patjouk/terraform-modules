variable "name" {}

variable "region" {}

variable "project_id" {}

variable "initial_node_count" { default = 1 }

variable "node_type" { default = "n1-standard-1" }

variable "http_load_balancing_disabled" { default = false }

variable "istio_disabled" { default = true }

variable "min_nodes_per_zone" { default = 1 }

variable "max_nodes_per_zone" { default = 5 }


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

variable "reloader_settings" {
  description = "Customize reloader helm chart"
  type        = map(string)
  default     = {}
}

variable "enable_flux" {
  default = false
}

variable "flux_git_url" {
  default = ""
}
