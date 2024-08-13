variable "location" {
    description = ""
    type = string
}
variable "name" {
    description = ""
    type = string
}
variable "public_subnet" {
 type = list(string)   
}
variable "bastion_subnet" {
 type = list(string)   
}


variable "cidr_block" {
    type = list(string)
}