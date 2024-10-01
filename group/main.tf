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
  custom_profile_attributes = jsonencode({
    "tags" = var.tags,
  })
}

module "rule" {
  count = var.user_conditions == null ? 0 : 1

  source          = "../expression"
  user_conditions = var.user_conditions
}

resource "okta_group_rule" "rule" {
  count = var.user_conditions == null && var.expression == "" ? 0 : 1


  name              = var.rule_name != "" ? var.rule_name : okta_group.group.id
  status            = "ACTIVE"
  group_assignments = [okta_group.group.id]
  expression_type   = "urn:okta:expression:1.0"
  expression_value  = var.user_conditions != null ? module.rule[0].expression : var.expression

  lifecycle {
    ignore_changes = [users_excluded]
  }
}

resource "okta_app_group_assignment" "assignment" {
  for_each = var.app_ids

  app_id   = each.value
  group_id = okta_group.group.id
}
