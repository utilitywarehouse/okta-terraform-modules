# expression

`expression` module will generate okta rule expression based on given array of 
group of user conditions(`list(list(map(string)))`).


While generating expression all key-value pair in a `map` will be considered as 
required (joined using `&&`) and generated map `expression` in a `group` will be
joined using OR(||) operator. groups are then joined using `&&` operator.


### Required inputs:
* `user_conditions` : The array of the conditions. each condition is represented 
  as map with attribute name as key and attribute value as map value. 
  Each key in the `condition map` must be a valid user attribute. 
  eg `[[{ common_att = "v" }],[{ att1 = "v1", att2 = "v2"}, {att1 = "v3"}]]`.

### Outputs:

* `expression` : The expression is the string containing generated okta expression based on `user_conditions`.

### operator:
module supports `_includes`, `_contains` and `_starts_with` operator which can be suffixed to the `key` name.
for these suffixed keys module will use okta `Arrays` and `Strings` function instead of `==` as shown..

`tags_includes = "contractor"` will be converted to `Arrays.contains(user.tags, "contractor")`

`teams_contains = "infra"` will be converted to `String.stringContains(user.teams, "infra")`

`teams_starts_with = "Technology/Security"` will be converted to `String.startsWith(user.teams, "Technology/Security")`

### Example:
```hcl
module "group_rule" {
  source = "github.com/utilitywarehouse/okta-terraform-modules//expression?ref=master"
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
      { teams_starts_with = "Technology/Security" },
    ]
  ]
}

output "group_rule" {
  value = module.group_rule.expression
}

# Outputs:
# group_rule = <<-EOT
#     (
#     (user.organization == "uw")
#     )
#     &&
#     (
#     (user.division == "Customer Services") ||
#     (user.division == "IT" && user.department == "Support") ||
#     (user.roleID == "2" && !user.isTemp && user.isManager) ||
#     (Arrays.contains(user.tags, "devs")) ||
#     (String.stringContains(user.teams, "infra"))
#     )
# EOT
```
