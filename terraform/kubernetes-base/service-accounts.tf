resource "kubernetes_service_account_v1" "deployer" {
  for_each = var.environments

  metadata {
    name      = "deployer-${each.key}"
    namespace = kubernetes_namespace_v1.environment[each.key].metadata[0].name

    labels = merge(local.common_labels, {
      "environment" = each.key
      "purpose"     = "application-deployment"
    })
  }

  automount_service_account_token = false
}
