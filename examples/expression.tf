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
      { tags_includes = "devs" },
      { teams_contains = "infra" },
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
#   (Arrays.contains(user.tags, "devs")) ||
#   (String.stringContains(user.teams, "infra"))
#   )
# EOT
