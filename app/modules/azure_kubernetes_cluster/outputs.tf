output "aks_config_command" {
  value       = format("az aks get-credentials --name '%s' --resource-group '%s' --file '~/.kube/aks_config' --overwrite-existing", azurerm_kubernetes_cluster.this.name, var.resource_group_name)
  description = "Command to receive the kube config"
  sensitive   = true
}

output "public_cluster_domain" {
  # TODO improve ;)
  # https://gitops-aks-1-dd398bae.hcp.germanywestcentral.azmk8s.io:443 => gitops-aks-1-dd398bae.hcp.germanywestcentral.azmk8s.io
  value = replace(replace(azurerm_kubernetes_cluster.this.kube_config.0.host, "https://", ""), ":443", "")
}

output "kube_config_secret" {
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  description = "output the kubeconfig for vault integration"
  sensitive   = true
}

output "kube_ca_cert" {
  value       = trimspace(base64decode(azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate))
  description = "output the ca cert from the cluster"
  sensitive   = true
}

output "kube_host" {
  value       = azurerm_kubernetes_cluster.this.kube_config.0.host
  description = "output the cluster host"
  sensitive   = true
}

output "aks_id" {
  value       = azurerm_kubernetes_cluster.this.id
  description = "Output of the AKS Cluster ID"
}

output "kube_cluster_name" {
  value       = azurerm_kubernetes_cluster.this.name
  description = "Output of the Kubernetes Cluster Name"
}
