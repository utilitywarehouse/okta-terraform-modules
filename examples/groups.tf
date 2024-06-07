terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

variable "org_name" {}

provider "okta" {
  org_name = var.org_name
  base_url = "oktapreview.com"
}


module "okta_module_test_group_without_rule" {
  source      = "../group"
  name        = "okta_module_test_group_without_rule"
  description = "some description ..."
  tags = [
    "team:team_a",
    "env:dev"
  ]
}

module "okta_module_test_group_with_condition" {
  source      = "../group"
  name        = "okta_module_test_group_with_condition"
  description = "some description ..."
  user_conditions = [
    [
      { organization = "uw" }
    ],
    [
      { division = "Customer Services" },
      { division = "IT", department = "Support" },
    ]
  ]
}

module "okta_module_test_group_with_expression" {
  source      = "../group"
  name        = "okta_module_test_group_with_expression"
  description = "some description ..."
  expression  = <<-EXPR
  Arrays.contains(user.tags, "team:john")
  EXPR
}
