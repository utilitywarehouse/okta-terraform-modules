# group

this module create both group and corresponding group rule resource if required based on given `user_conditions`

use variable `user_conditions` to provide conditions in the form of [attribute lists](../expression/readme.md)
variable `expression` can be used to provide okta group rule expression string


### Required inputs:

* `name` : The name of the Okta Group.

* `description` : The description of the Okta Group.

### Optional inputs:
* `rule_name`: The name of the Group Rule. if not provided group `id` will be used for rule name.
  group `id` is used since okta has 50 char limit on group name.

* `expression`: The okta expression string.

* `user_conditions` : array of the conditions. each condition is represented as map with attribute 
  name as key and attribute value as map value. Each key in the `condition map` must be a valid user attribute.
  eg `[[{ common_att = "v" }], [{ att1 = "v1", att2 = "v2"}, {att1 = "v3"}]]`.

  If both `expression` & `user_conditions` is not provided then module will `not` create corresponding rule. 

* `app_ids`: applications ids to associate group with. modules creates `okta_app_group_assignment`
  resource for each application.
  
### Outputs:

* `group_id` : The ID of the Okta Group.

* `rule_id` : The ID of the Group Rule.

### Example:
```hcl
module "app_access_with_condition" {
  source      = "github.com/utilitywarehouse/okta-terraform-modules//group?ref=master"
  name        = "app_access"
  description = "some description ..."
  tags = [
    "team:team_a",
    "env:dev"
  ]

  app_ids = {
    "app_0" : okta_app_oauth.example1.id,
    "app_1" : okta_app_oauth.example2.id,
  }
  
  user_conditions = [
    [{ organization = "uw" }],
    [
      { division = "Customer Services" },
      { division = "IT", department = "Support" },
      { roleID = 2, isManager = true, isTemp = false },
      { tags_includes = "devs" },
      { teams_contains = "infra" },
    ]
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
         (
         (user.organization == "uw")
         )
         &&
         (
         (user.division == "Customer Services") ||
         (user.division == "IT" && user.department == "Support") ||
         (user.roleID == "2" && !user.isTemp && user.isManager) ||
         (Arrays.contains(user.tags, "devs")) ||
         (String.stringContains(user.teams, "infra"))
         )
      EOT
    + group_assignments = (known after apply)
    + id                = (known after apply)
    + name              = (known after apply)
    + status            = "ACTIVE"
  }

# module.app_access_with_condition.okta_app_group_assignment.assignment["app_0"] will be created
+ resource "okta_app_group_assignment" "assignment" {
    + app_id            = (known after apply)
    + group_id          = (known after apply)
    + id                = (known after apply)
    + retain_assignment = false
  }

# module.app_access_with_condition.okta_app_group_assignment.assignment["app_1"] will be created
+ resource "okta_app_group_assignment" "assignment" {
    + app_id            = (known after apply)
    + group_id          = (known after apply)
    + id                = (known after apply)
    + retain_assignment = false
  }
```


### Import
* command line
  ```bash
  terraform import module.example.okta_group.group <group_id>
  terraform import 'module.example.okta_group_rule.rule[0]' <rule_id>
  terraform import 'module.example.okta_app_group_assignment.assignment["<app_id>"]' <app_id>/<group_id>
  ```
* import block
  ```
  import {
    to = module.example.okta_group.group
    id = <group_id>
  }
  import {
    to = module.example.okta_group_rule.rule[0]
    id = <rule_id>
  }
  import {
    to = module.example.okta_app_group_assignment.assignment["<key>"]
    id = <app_id>/<group_id>
  }
  ```