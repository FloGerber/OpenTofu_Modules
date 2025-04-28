resource "kubernetes_secret" "this" {
  metadata {
    name = "secrets-store-creds"
    labels = {
      "secrets-store.csi.k8s.io/used" = true
    }
  }

  data = {
    clientid     = "${var.key_vault_service_principal_client_id}"
    clientsecret = "${var.key_vault_service_principal_client_secret}"
  }

  type = "Opaque"
}


resource "kubernetes_manifest" "this" {
  count = 0
  manifest = {
    apiVersion = "secrets-store.csi.x-k8s.io/v1"
    kind       = "SecretProviderClass"

    metadata = {
      name      = "azure-sync"
      namespace = "default"
    }

    spec = {
      provider = "azure"

      parameters = {
        useVMManagedIdentity = false
        #userAssignedIdentityID = "${var.key_vault_read_sp_id}"
        keyvaultName = "${var.key_vault_name}"
        tenantId     = "${var.tenant_id}"
      }
    }
  }
}
