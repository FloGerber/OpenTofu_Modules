output "kube_config" {
  value       = module.aks.kube_config_secret
  description = "Output of the Kubeconfig to inject into Keyvault"
  sensitive   = true
}

output "kube_ca_cert" {
  value       = module.aks.kube_ca_cert
  description = "output the ca cert from the cluster"
  sensitive   = true
}

output "kube_host" {
  value       = module.aks.kube_host
  description = "output the cluster host"
  sensitive   = true
}

output "k8s_service_principal_object_id" {
  value       = module.k8s_service_principal.object_id
  description = "output k8s_service_principal_object_id"
}

output "aks_gitlab_service_principal_id" {
  value       = module.aks_gitlab_service_principal.client_id
  description = "Output of the Gitlab AKS Service Principal"
  sensitive   = true
}

output "aks_gitlab_service_principal_secret" {
  value       = module.aks_gitlab_service_principal.client_secret
  description = "Output of the Gitlab AKS Service Princpal Secret"
  sensitive   = true
}
