data "azuread_client_config" "this" {}

data "gitlab_group" "gitops-apps" {
  full_path = "devops/gitops/apps"
}

resource "null_resource" "k8s_gpg" {
  provisioner "local-exec" {
    command = "echo '${var.kube_config}' | gpg --yes --batch --passphrase=${var.gpg_encryption_key} --output kubeconfig.gpg --symmetric --cipher-algo AES256"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ./kubeconfig.gpg"
  }
}

data "local_sensitive_file" "k8s_encrypted" {
  filename = "kubeconfig.gpg"

  depends_on = [
    null_resource.k8s_gpg
  ]
}

data "local_sensitive_file" "ssh_key" {
  filename = "/root/.ssh/ssh_key"
}

module "gitlab_group_variables" {
  source = "../../modules/gitlab"

  group_variables = {
    terraform_ssh_key = {
      group = data.gitlab_group.gitops-apps.id
      key   = "${upper(var.environment)}_TF_SSH_KEY"
      value = data.local_sensitive_file.ssh_key.content_base64
    }
    proxy_url = {
      group = data.gitlab_group.gitops-apps.id
      key   = "${upper(var.environment)}_PROXY_URL"
      value = var.proxy_url
    }
    kube_config = {
      group = data.gitlab_group.gitops-apps.id
      key   = "${upper(var.environment)}_KUBE_CONFIG"
      value = data.local_sensitive_file.k8s_encrypted.content_base64
    }
    aks_service_principal_id = {
      group = data.gitlab_group.gitops-apps.id
      key   = "${upper(var.environment)}_AAD_SERVICE_PRINCIPAL_CLIENT_ID"
      value = var.aks_gitlab_service_principal_id
    }
    aks_service_principal_secret = {
      group = data.gitlab_group.gitops-apps.id
      key   = "${upper(var.environment)}_AAD_SERVICE_PRINCIPAL_CLIENT_SECRET"
      value = var.aks_gitlab_service_principal_secret
    }
  }
}

module "vault_read_service_principal" {
  source                          = "../../modules/service_principal"
  name                            = "secret_user"
  environment                     = var.environment
  password_rotation_interval_days = 14
  description                     = "Create a Service Principal for Secret Read Access on Env ${var.environment}"
}

module "rbac" {
  source = "../../modules/rbac"
  role_assignment = [
    {
      description          = "Vault Secret Read Service Principal"
      scope                = var.vault_id
      role_definition_name = "Key Vault Secrets User"
      principal_id         = module.vault_read_service_principal.object_id
    },
    {
      description          = "Access to Storage Account (Persistent Volumes)"
      scope                = module.secret_provider_class.storage_account_id
      role_definition_name = "Storage File Data SMB Share Contributor"
      principal_id         = var.k8s_service_principal_object_id
    },
    {
      description          = "Access to Resource Group"
      scope                = module.secret_provider_class.resource_group_id
      role_definition_name = "Contributor"
      principal_id         = var.k8s_service_principal_object_id
    },
  ]
}

module "secret_provider_class" {
  source                                    = "../../modules/kubectl"
  environment                               = var.environment
  key_vault_name                            = var.vault_name
  key_vault_read_sp_id                      = module.vault_read_service_principal.object_id
  tenant_id                                 = data.azuread_client_config.this.tenant_id
  key_vault_service_principal_client_id     = module.vault_read_service_principal.client_id
  key_vault_service_principal_client_secret = module.vault_read_service_principal.client_secret
  kube_ca_cert                              = var.kube_ca_cert
  kube_host                                 = var.kube_host
  location_name                             = var.location_name
  sku_name                                  = "StandardSSD_LRS"
  storage_account_name                      = join("", [substr("${var.environment}", 0, 1), "azgwcstg001"])
  storage_class_name                        = "azure-file-storage-dynamic"
  proxy_url                                 = var.proxy_url
}

