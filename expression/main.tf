locals {
  # input
  # user_conditions = [
  #   {
  #     AK1 = "AV1"
  #     AK2 = 2
  #   },
  #   {
  #     BK1 = "BV1"
  #     BK2 = false
  #   }
  # ]

  attributeStrs = [
    for condition in var.user_conditions : [
      # reverse key to get attributes in order of organisation,division,department
      for k in reverse(keys(condition)) :
      format("user.%s == %s", k,
        "%{if condition[k] == "true" || condition[k] == "false"}${condition[k]}%{else}\"${condition[k]}\"%{endif}"
      )
    ]
  ]
  # attributeStrs = [
  #  [
  #    "user.AK1 == \"AV1\"",
  #    "user.AK2 == \"2\"",
  #  ],
  #  [
  #    "user.BK1 == \"BV1\"",
  #    "user.BK2 == false",
  #  ],
  # ]

  paths = [
    for attrs in local.attributeStrs :
    format("(%s)", join(" && ", attrs))
  ]
  # paths = [
  #   "(user.AK2 == \"2\" && user.AK1 == \"AV1\")",
  #   "(user.BK2 == false && user.BK1 == \"BV1\")",
  # ]

  expression = join(" ||\n", local.paths)
  # expression = <<EOT
  # (user.AK2 == "2" && user.AK1 == "AV1") ||
  # (user.BK2 == false && user.BK1 == "BV1")
  # EOT
}
