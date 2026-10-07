resource "kubernetes_network_policy_v1" "default_deny_ingress" {
  for_each = var.environments

  metadata {
    name      = "default-deny-ingress"
    namespace = kubernetes_namespace_v1.environment[each.key].metadata[0].name

    labels = merge(local.common_labels, {
      "environment" = each.key
    })
  }

  spec {
    pod_selector {}

    policy_types = [
      "Ingress"
    ]
  }
}

resource "kubernetes_network_policy_v1" "allow_same_namespace" {
  for_each = var.environments

  metadata {
    name      = "allow-same-namespace"
    namespace = kubernetes_namespace_v1.environment[each.key].metadata[0].name

    labels = merge(local.common_labels, {
      "environment" = each.key
    })
  }

  spec {
    pod_selector {}

    ingress {
      from {
        pod_selector {}
      }
    }

    policy_types = [
      "Ingress"
    ]
  }
}
