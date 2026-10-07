output "environment_namespaces" {
  description = "Namespaces created for the application environments"

  value = {
    for environment, namespace in kubernetes_namespace_v1.environment :
    environment => namespace.metadata[0].name
  }
}

output "deployer_service_accounts" {
  description = "Service accounts created for deployments"

  value = {
    for environment, account in kubernetes_service_account_v1.deployer :
    environment => account.metadata[0].name
  }
}

output "resource_quotas" {
  description = "Resource quotas assigned to each environment"

  value = {
    for environment, quota in kubernetes_resource_quota_v1.environment :
    environment => quota.metadata[0].name
  }
}
