resource "kubernetes_resource_quota_v1" "environment" {
  for_each = var.environments

  metadata {
    name      = "${each.key}-resource-quota"
    namespace = kubernetes_namespace_v1.environment[each.key].metadata[0].name

    labels = merge(local.common_labels, {
      "environment" = each.key
    })
  }

  spec {
    hard = {
      "pods"            = tostring(each.value.pod_quota)
      "requests.cpu"    = each.value.requests_cpu
      "requests.memory" = each.value.requests_memory
      "limits.cpu"      = each.value.limits_cpu
      "limits.memory"   = each.value.limits_memory
    }
  }
}
