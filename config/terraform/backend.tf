# SUBSCRIPTION_HASH is a short 4-char consistent hash of the longer subscription id.
# This is useful because azure storage account names are not allowed special characters and are limited to 24 chars.
terraform {
  backend "azurerm" {
    resource_group_name  = "provisioning"                                          #"<%= expansion(':ENV-:LOCATION') %>"
    storage_account_name = "xxxx"                                             #"<%= expansion('ts:SUBSCRIPTION_HASH:LOCATION:ENV') %>"
    container_name       = "workspaces"                                            #"terraform-state"
    key                  = "<%= expansion(':ENV/:BUILD_DIR/terraform.tfstate') %>" #"<%= expansion(':LOCATION/:ENV/:BUILD_DIR/terraform.tfstate') %>"
  }
}
