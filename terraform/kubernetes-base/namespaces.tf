resource "kubernetes_namespace_v1" "environment" {
  for_each = var.environments

  metadata {
    name = each.key

    labels = merge(local.common_labels, {
      "environment" = each.key
    })
  }
}
