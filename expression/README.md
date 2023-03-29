# expression

`expression` module will generate okta rule expression based on given array of user conditions(`list(map(string))`).


While generating expression all key-value pair in a `map` will be considered as required (joined using `&&`) and generated map `expression` in a `list` will be joined using OR(||) operator.


### Required inputs:
* `user_conditions` : The array of the conditions. each condition is represented as map with attribute name as key and attribute value as map value. Each key in the `condition map` must be a valid user attribute. eg `[{ att1 = "v1", att2 = "v2"}, {att1 = "v3"}]`.

### Outputs:

* `expression` : The expression is the string containing generated okta expression based on `user_conditions`.

### Example:
```hcl
module "group_rule" {
  source = ""github.com/utilitywarehouse/okta-terraform-modules//expression?ref=master""
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
```
