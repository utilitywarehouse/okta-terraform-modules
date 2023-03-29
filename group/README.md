# group

this module create both group and corresponding group rule resource if required based on given `user_conditions`

use variable `user_conditions` to provide conditions in the form of [attribute lists](../expression/readme.md)
variable `expression` can be used to provide okta group rule expression string


### Required inputs:

* `name` : The name of the Okta Group.

* `description` : The description of the Okta Group.

### Optional inputs:
* `rule_name`: The name of the Group Rule. if not provided group `name` will be used for rule name.

* `expression`: The okta expression string.

* `user_conditions` : array of the conditions. each condition is represented as map with attribute name as key and attribute value as map value. Each key in the `condition map` must be a valid user attribute. eg `[{ att1 = "v1", att2 = "v2"}, {att1 = "v3"}]`.

If both `expression` & `user_conditions` is not provided then module will `not` create corresponding rule. 

### Outputs:

* `group_id` : The ID of the Okta Group.

* `rule_id` : The ID of the Group Rule.

### Example:
```hcl
module "app_access_with_condition" {
  source      = "github.com/utilitywarehouse/okta-terraform-modules//group?ref=master"
  name        = "app_access"
  description = "some description ..."
  user_conditions = [
    { organization = "uw", division = "Customer Services" },
    { organization = "uw", division = "IT", department = "Support" },
    { roleID = 2, isManager = true },
  ]
}
```

creates following...

```
# module.app_access_with_condition.okta_group.group will be created
+ resource "okta_group" "group" {
    + description = "some description ..."
    + id          = (known after apply)
    + name        = "app_access"
    + skip_users  = false
  }

# module.app_access_with_condition.okta_group_rule.group_rule[0] will be created
+ resource "okta_group_rule" "group_rule" {
    + expression_type   = "urn:okta:expression:1.0"
    + expression_value  = <<-EOT
          (user.organization == "uw" && user.division == "Customer Services") ||
          (user.organization == "uw" && user.division == "IT" && user.department == "Support") ||
          (user.roleID == "2" && user.isManager == true)
      EOT
    + group_assignments = (known after apply)
    + id                = (known after apply)
    + name              = "app_access"
    + status            = "ACTIVE"
  }
```


### Import
```bash
terraform import module.example.okta_group.group <group_id>
terraform import 'module.example.okta_group_rule.rule[0]' <rule_id>
```
