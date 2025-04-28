# need this one for azuread_application?
data "azuread_client_config" "client_config" {}

resource "azuread_application" "this" {
  display_name = "${var.environment}-${var.name}-sp"
  owners       = [data.azuread_client_config.client_config.object_id]
}

resource "azuread_service_principal" "this" {
  application_id               = azuread_application.this.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.client_config.object_id]
  description                  = var.description
}

resource "time_rotating" "this" {
  rotation_days = var.password_rotation_interval_days
}

resource "azuread_service_principal_password" "this" {
  service_principal_id = azuread_service_principal.this.id
  rotate_when_changed = {
    rotation = time_rotating.this.id
  }

  # getting error with Service Principal not found in Directory otherwise
  # bug in azuread provider module which _should_ be fixed since 2.6.0
  provisioner "local-exec" {
    command = <<EOF
  echo "Waiting for service principal..."
  sleep 30
EOF
  }
}
