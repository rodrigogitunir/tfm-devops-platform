variable "kubeconfig_path" {
  description = "Path to the kubeconfig used to access the Minikube cluster"
  type        = string
  default     = "~/.kube/tfm-devops-config"
}

variable "kubeconfig_context" {
  description = "Kubernetes context used by Terraform"
  type        = string
  default     = "tfm-devops"
}

variable "project_name" {
  description = "Name used to label Kubernetes resources"
  type        = string
  default     = "tfm-devops-platform"
}

variable "environments" {
  description = "Base configuration for each Kubernetes environment"

  type = map(object({
    pod_quota              = number
    requests_cpu           = string
    requests_memory        = string
    limits_cpu             = string
    limits_memory          = string
    default_request_cpu    = string
    default_request_memory = string
    default_limit_cpu      = string
    default_limit_memory   = string
  }))
}
