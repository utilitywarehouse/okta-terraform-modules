module "group_rule" {
  source = "../expression"
  user_conditions = [
    { organization = "uw", division = "Customer Services" },
    { organization = "uw", division = "IT", department = "Support" },
    { roleID = 2, isManager = true },
  ]
}

output "group_rule" {
  value = module.group_rule.expression
}

# Outputs:
#  group_rule = <<-EOT
#       (user.organization == "uw" && user.division == "Customer Services") ||
#       (user.organization == "uw" && user.division == "IT" && user.department == "Support") ||
#       (user.roleID == "2" && user.isManager == true)
#  EOT
