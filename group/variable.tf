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
  type     = list(list(map(string)))
  default  = null
  nullable = true
}

variable "app_ids" {
  type        = map(string)
  description = "Apps to associate group with"
  default     = {}
}
