terraform {
  experiments = [module_variable_optional_attrs]
  required_providers {

    gitlab = {
      source = "gitlabhq/gitlab"
    }
  }
}
