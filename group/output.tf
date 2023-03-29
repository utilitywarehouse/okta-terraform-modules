output "group_id" {
  value = okta_group.group.id
}

output "rule_id" {
  value = length(okta_group_rule.rule) == 1 ? okta_group_rule.rule[0].id : ""
}
