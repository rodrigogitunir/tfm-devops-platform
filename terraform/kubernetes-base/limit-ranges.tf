resource "kubernetes_limit_range_v1" "environment" {
  for_each = var.environments

  metadata {
    name      = "${each.key}-default-limits"
    namespace = kubernetes_namespace_v1.environment[each.key].metadata[0].name

    labels = merge(local.common_labels, {
      "environment" = each.key
    })
  }

  spec {
    limit {
      type = "Container"

      default = {
        cpu    = each.value.default_limit_cpu
        memory = each.value.default_limit_memory
      }

      default_request = {
        cpu    = each.value.default_request_cpu
        memory = each.value.default_request_memory
      }
    }
  }
}
