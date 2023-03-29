terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

resource "okta_group" "group" {
  name        = var.name
  description = var.description
}

module "rule" {
  source          = "../expression"
  user_conditions = var.user_conditions
}

resource "okta_group_rule" "rule" {
  count = length(var.user_conditions) == 0 && var.expression == "" ? 0 : 1


  name              = var.rule_name != "" ? var.rule_name : var.name
  status            = "ACTIVE"
  group_assignments = [okta_group.group.id]
  expression_type   = "urn:okta:expression:1.0"
  expression_value  = length(var.user_conditions) > 0 ? module.rule.expression : var.expression

  lifecycle {
    ignore_changes = [users_excluded]
  }
}
