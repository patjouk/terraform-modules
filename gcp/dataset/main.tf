locals {
  default_access = [{
    role          = "READER"
    special_group = "projectReaders"
  },
    {
      role          = "OWNER"
      special_group = "projectOwners"
    },
    {
      role          = "OWNER"
      user_by_email = "${var.owner_email}"
    },
  ]
}

variable "project" {}
variable "name" {}

variable "description" {
  default = ""
}

variable "mozilla_data_classification" {}
variable "data_owner" {}
variable "data_consumer" {}
variable "data_source" {}

variable "retention_period" {
  default = "forever"
}

variable "has_pii" {
  default = "false"
}

variable "location" {
  default = "US"
}

variable "owner_email" {}

variable "extra_access" {
  default = []
}

variable "extra_labels" {
  default = {}
}

resource "google_bigquery_dataset" "dataset" {
  project                    = "${var.project}"
  dataset_id                 = "${var.name}"
  description                = "${var.description}"
  location                   = "${var.location}"
  delete_contents_on_destroy = "false"

  access = ["${concat(local.default_access,list(map("role","OWNER","user_by_email","${var.owner_email}")),var.extra_access)}"]

  labels = "${merge(var.extra_labels, map("mozilla_data_classification","${var.mozilla_data_classification}","data_owner","${var.data_owner}","data_consumer","${var.data_consumer}","data_source","${var.data_source}","retention_period","${var.retention_period}","has_pii","${var.has_pii}"))}"
}
