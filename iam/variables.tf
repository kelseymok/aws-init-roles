variable "org" {
  type        = string
  default = "managed-users"
  description = "The name of a group of managed users"
}

variable "developer-trusted-entities" {
  type        = list(string)
  description = "List of IAM user ARNs who can assume the Develpoer role"
}

variable "administrator-trusted-entities" {
  type        = list(string)
  description = "List of IAM user ARNs who can assume the Administrator role"
}