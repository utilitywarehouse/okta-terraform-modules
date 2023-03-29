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

variable "user_conditions" {
  type    = list(map(string))
  default = []
}
