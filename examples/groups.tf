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

resource "okta_app_oauth" "example1" {
  label                      = "example1"
  type                       = "browser"
  grant_types                = ["authorization_code"]
  redirect_uris              = ["https://localhost:3000/callback"]
  response_types             = ["code"]
  token_endpoint_auth_method = "none" # toggles PKCE on
  refresh_token_rotation     = "ROTATE"
  pkce_required              = true
}

resource "okta_app_oauth" "example2" {
  label                      = "example2"
  type                       = "browser"
  grant_types                = ["authorization_code"]
  redirect_uris              = ["https://localhost:3000/callback"]
  response_types             = ["code"]
  token_endpoint_auth_method = "none" # toggles PKCE on
  refresh_token_rotation     = "ROTATE"
  pkce_required              = true
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

  app_ids = {
    "app_0" : okta_app_oauth.example1.id,
    "app_1" : okta_app_oauth.example2.id,
  }

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
