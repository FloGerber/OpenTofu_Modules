terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.6.1"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "2.0.0-preview-2"
    }
  }
}

provider "kubernetes" {
  host                   = var.kube_host
  cluster_ca_certificate = var.kube_ca_cert
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "kubelogin"
    args = [
      "get-token",
      "--login",
      "azurecli",
      "--server-id",
      "6dae42f8-4368-4678-94ff-3960e28e3630" #Default Server ID for AzureAD https://github.com/Azure/kubelogin#exec-plugin-format
    ]
  }

  proxy_url = var.proxy_url
}
