locals {
  common_labels = {
    "app.kubernetes.io/managed-by" = "terraform"
    "app.kubernetes.io/part-of"    = var.project_name
    "tfm.unir/environment-model"   = "multi-environment"
  }
}
