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
  #     { CK1_includes = "CV1,CV2", CK2 = true },
  #     { DK1_contains = "DV1" },
  #     { EK1_starts_with = "EV1" }
  #   ]
  # ]

  # Step 1: Generate the individual string components for each attribute.
  # This is step converts each key-value pair into its expression format.
  attributeStrsGroups = [
    for conditions in var.user_conditions : [
      for condition in conditions : flatten([
        for k in reverse(keys(condition)) : (
          strcontains(k, "_includes") ? [
            for item in split(",", condition[k]) :
            format("Arrays.contains(user.%s, \"%s\")", trimsuffix(k, "_includes"), trimspace(item))
          ] :

          strcontains(k, "_contains") ? [
            format("String.stringContains(user.%s, \"%s\")", trimsuffix(k, "_contains"), condition[k])
          ] :

          strcontains(k, "_starts_with") ? [
            format("String.startsWith(user.%s, \"%s\")", trimsuffix(k, "_starts_with"), condition[k])
          ] :

          condition[k] == "true" ? [
            format("user.%s", k)
          ] :

          condition[k] == "false" ? [
            format("!user.%s", k)
          ] :

          [
            format("user.%s == \"%s\"", k, condition[k])
          ]
        )
      ])
    ]
  ]
  # attributeStrsGroups = [
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
  #       "Arrays.contains(user.CK1, \"CV2\")",
  #     ],
  #     [
  #       "String.stringContains(user.DK1, \"DV1\")",
  #     ],
  #     [
  #       "String.startsWith(user.EK1, \"EV1\")",
  #     ],
  #   ],
  # ]

  # Step 2: Join the attribute strings for each condition with "&&".
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
  #     "(user.CK2 && Arrays.contains(user.CK1, \"CV1\") && Arrays.contains(user.CK1, \"CV2\"))",
  #     "(String.stringContains(user.DK1, \"DV1\"))",
  #     "(String.startsWith(user.EK1, \"EV1\"))",
  #   ],
  # ]

  # Step 3: Join the condition strings for each group with "||".
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
  #     (user.CK2 && Arrays.contains(user.CK1, "CV1") && Arrays.contains(user.CK1, "CV2")) ||
  #     (String.stringContains(user.DK1, "DV1")) ||
  #     (String.startsWith(user.EK1, "EV1"))
  #   EOT,
  # ]

  # Step 4: Join the final group strings with "&&" and wrap them.
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
  #     (user.CK2 && Arrays.contains(user.CK1, "CV1") && Arrays.contains(user.CK1, "CV2")) ||
  #     (String.stringContains(user.DK1, "DV1")) ||
  #     (String.startsWith(user.EK1, "EV1"))
  #     )
  # EOT
}
