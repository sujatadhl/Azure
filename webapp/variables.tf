variable "location" {
  description = ""
  type        = string
}
variable "name" {
  description = ""
  type        = string
}
variable "public_subnet" {
  type = list(string)
}
variable "delegated_subnet" {
  type = list(string)
}

variable "cidr_block" {
  type = list(string)
}

variable "admin_username" {
  type        = string
  description = "The administrator username of the SQL logical server."
}

variable "admin_password" {
  type        = string
  description = "The administrator password of the SQL logical server."
}
