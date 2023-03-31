variable "name" {
}

variable "description" {
}

variable "rule_name" {
  default = ""
}

variable "expression" {
  default = ""
}

variable "tags" {
  type     = list(string)
  default  = null
  nullable = true
}

variable "user_conditions" {
  type     = list(map(string))
  default  = null
  nullable = true
}
