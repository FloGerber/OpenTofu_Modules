variable "group_variables" {
  type = map(object({
    group             = string
    value             = string
    key               = string
    protected         = optional(bool)
    masked            = optional(bool)
    environment_scope = optional(string)
    variable_type     = optional(string)
  }))
}
