locals {
  # input
  # user_conditions = [
  #   [
  #     { AllAK1 = "allAV1", AllAK2 = 3 },
  #     { AllBK1 = "allBV1", AllBK2 = true },
  #   ],
  #   [
  #     { AK1 = "AV1", AK2 = 2 },
  #     { BK1 = "BV1", BK2 = false },
  #     { CK1_includes = "CV1", CK2 = true },
  #     { DK1_contains = "DV1" }
  #   ]
  # ]

  attributeStrsGroups = [
    for conditions in var.user_conditions : [
      for condition in conditions : [
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
  ]
  # attributeStrsGroups = [
  # group_rule = [
  #   [
  #     [
  #       "user.AllAK2 == \"3\"",
  #       "user.AllAK1 == \"allAV1\"",
  #     ],
  #     [
  #       "user.AllBK2",
  #       "user.AllBK1 == \"allBV1\"",
  #     ],
  #   ],
  #   [
  #     [
  #       "user.AK2 == \"2\"",
  #       "user.AK1 == \"AV1\"",
  #     ],
  #     [
  #       "!user.BK2",
  #       "user.BK1 == \"BV1\"",
  #     ],
  #     [
  #       "user.CK2",
  #       "Arrays.contains(user.CK1, \"CV1\")",
  #     ],
  #     [
  #       "String.stringContains(user.DK1, \"DV1\")",
  #     ],
  #   ],
  # ]


  pathsGroups = [
    for attributeStrs in local.attributeStrsGroups : [
      for attrs in attributeStrs :
      format("(%s)", join(" && ", attrs))
    ]
  ]
  # pathsGroups = [
  #   [
  #     "(user.AllAK2 == \"3\" && user.AllAK1 == \"allAV1\")",
  #     "(user.AllBK2 && user.AllBK1 == \"allBV1\")",
  #   ],
  #   [
  #     "(user.AK2 == \"2\" && user.AK1 == \"AV1\")",
  #     "(!user.BK2 && user.BK1 == \"BV1\")",
  #     "(user.CK2 && Arrays.contains(user.CK1, \"CV1\"))",
  #     "(String.stringContains(user.DK1, \"DV1\"))",
  #   ],
  # ]

  expressionGroups = [
    for paths in local.pathsGroups :
    join(" ||\n", paths)
  ]

  # expressionGroups = [
  #   <<-EOT
  #     (user.AllAK2 == "3" && user.AllAK1 == "allAV1") ||
  #     (user.AllBK2 && user.AllBK1 == "allBV1")
  #   EOT,
  #   <<-EOT
  #     (user.AK2 == "2" && user.AK1 == "AV1") ||
  #     (!user.BK2 && user.BK1 == "BV1") ||
  #     (user.CK2 && Arrays.contains(user.CK1, "CV1")) ||
  #     (String.stringContains(user.DK1, "DV1"))
  #   EOT,
  # ]


  expression = format("(\n%s\n)", join("\n)\n&&\n(\n", local.expressionGroups))
  # expression = <<-EOT
  #     (
  #     (user.AllAK2 == "3" && user.AllAK1 == "allAV1") ||
  #     (user.AllBK2 && user.AllBK1 == "allBV1")
  #     )
  #     &&
  #     (
  #     (user.AK2 == "2" && user.AK1 == "AV1") ||
  #     (!user.BK2 && user.BK1 == "BV1") ||
  #     (user.CK2 && Arrays.contains(user.CK1, "CV1")) ||
  #     (String.stringContains(user.DK1, "DV1"))
  #     )
  # EOT
}
