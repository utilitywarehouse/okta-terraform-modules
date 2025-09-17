module "group_rule" {
  source = "../expression"
  user_conditions = [
    [
      { organization = "uw" }
    ],
    [
      { division = "Customer Services" },
      { division = "IT", department = "Support" },
      { roleID = 2, isManager = true, isTemp = false },
      { tags_includes = "devs,product" },
      { teams_contains = "infra" },
      { teams_starts_with = "Technology/Security" }
    ]
  ]
}

output "group_rule" {
  value = module.group_rule.expression
}

# Outputs:
# group_rule = <<-EOT
#   (
#   (user.organization == "uw")
#   )
#   &&
#   (
#   (user.division == "Customer Services") ||
#   (user.division == "IT" && user.department == "Support") ||
#   (user.roleID == "2" && !user.isTemp && user.isManager) ||
#   (Arrays.contains(user.tags, "devs") && Arrays.contains(user.tags, "product")) ||
#   (String.stringContains(user.teams, "infra")) ||
#   (String.startsWith(user.teams, "Technology/Security"))
#   )
# EOT
