resource "gitlab_group_variable" "this" {
  for_each          = var.group_variables
  group             = each.value.group
  key               = each.value.key
  value             = each.value.value
  protected         = each.value.protected == null ? true : false
  masked            = each.value.masked == null ? true : false
  environment_scope = each.value.environment_scope == null ? "*" : each.value.environment_scope
}
