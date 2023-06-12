locals {
  # input
  # user_conditions = [
  # { AK1 = "AV1", AK2 = 2 },
  # { BK1 = "BV1", BK2 = false },
  # { CK1_includes = "CV1", CK2 = true },
  # { DK1_contains = "DV1" }
  # ]

  attributeStrs = [
    for condition in var.user_conditions : [
      # reverse key to get attributes in order of organisation,division,department
      for k in reverse(keys(condition)) :
      trimspace(<<EOT
%{if condition[k] == "true"}
  user.${k}
%{else}
  %{if condition[k] == "false"}
    !user.${k}
  %{else}
    %{if length(regexall("_includes", "${k}")) > 0}
      Arrays.contains(user.${trimsuffix(k, "_includes")}, "${condition[k]}")
    %{else}
      %{if length(regexall("_contains", "${k}")) > 0}
        String.stringContains(user.${trimsuffix(k, "_contains")}, "${condition[k]}")
      %{else}
        ${format("user.%s == \"%s\"", k, "${condition[k]}")}
      %{endif}
    %{endif}
  %{endif}
%{endif}
EOT
      )
    ]
  ]
  # attributeStrs = [
  #   [
  #     "user.AK2 == \"2\"",
  #     "user.AK1 == \"AV1\"",
  #   ],
  #   [
  #     "!user.BK2",
  #     "user.BK1 == \"BV1\"",
  #   ],
  #   [
  #     "user.CK2",
  #     "Arrays.contains(user.CK1, \"CV1\")",
  #   ],
  #   [
  #     "String.stringContains(user.DK1, \"DV1\")",
  #   ],
  # ]

  paths = [
    for attrs in local.attributeStrs :
    format("(%s)", join(" && ", attrs))
  ]
  # paths = [
  #   "(user.AK2 == \"2\" && user.AK1 == \"AV1\")",
  #   "(!user.BK2 && user.BK1 == \"BV1\")",
  #   "(user.CK2 && Arrays.contains(user.CK1, \"CV1\"))",
  #   "(String.stringContains(user.DK1, \"DV1\"))",
  # ]

  expression = join(" ||\n", local.paths)
  # expression = <<EOT
  #  (user.AK2 == "2" && user.AK1 == "AV1") ||
  #  (!user.BK2 && user.BK1 == "BV1") ||
  #  (user.CK2 && Arrays.contains(user.CK1, "CV1")) ||
  #  (String.stringContains(user.DK1, "DV1"))
  # EOT
}
