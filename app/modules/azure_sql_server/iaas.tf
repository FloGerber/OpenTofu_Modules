# SQL Settings
resource "azurerm_mssql_virtual_machine" "azurerm_sqlvmmanagement" {

  virtual_machine_id               = azurerm_virtual_machine.windows_vm.id
  sql_license_type                 = "PAYG"
  sql_connectivity_port            = 1433
  sql_connectivity_type            = "PRIVATE"
  sql_connectivity_update_password = var.sql_connectivity_update_password
  sql_connectivity_update_username = var.sql_connectivity_update_username

  auto_patching {
    day_of_week                            = "Sunday"
    maintenance_window_duration_in_minutes = 60
    maintenance_window_starting_hour       = 2
  }

  storage_configuration {
    disk_type             = "NEW"  # (Required) The type of disk configuration to apply to the SQL Server. Valid values include NEW, EXTEND, or ADD.
    storage_workload_type = "OLTP" # (Required) The type of storage workload. Valid values include GENERAL, OLTP, or DW.

    # The storage_settings block supports the following:
    data_settings {
      default_file_path = var.default_file_path_data # (Required) The SQL Server default path
      luns              = [0]                        #azurerm_virtual_machine_data_disk_attachment.datadisk_attach[count.index].lun]
    }

    log_settings {
      default_file_path = var.default_file_path_log # (Required) The SQL Server default path
      luns              = [1]                       #azurerm_virtual_machine_data_disk_attachment.logdisk_attach[count.index].lun] # (Required) A list of Logical Unit Numbers for the disks.
    }

  }
}
