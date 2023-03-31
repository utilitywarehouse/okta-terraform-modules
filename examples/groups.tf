terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

provider "okta" {
  org_name = "preview"
  base_url = "oktapreview.com"
}


module "app_group_without_rule" {
  source      = "../group"
  name        = "appapp_group_without_rule_access"
  description = "some description ..."
  tags = [
    "team:team_a",
    "env:dev"
  ]
}

module "app_access_with_condition" {
  source      = "../group"
  name        = "app_access"
  description = "some description ..."
  user_conditions = [
    { organization = "uw", division = "Customer Services" },
    { organization = "uw", division = "IT", department = "Support" },
  ]
}

module "app_group_with_expression" {
  source      = "../group"
  name        = "appapp_group_with_expression"
  description = "some description ..."
  expression  = <<-EXPR
  Arrays.contains(user.tags, "team:john")
  EXPR
}
