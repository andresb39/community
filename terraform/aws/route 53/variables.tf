variable "region" {
    default = "us-east-1"
}
# Si necesitamos usar profiles descomentar las siguientes lineas.
variable "profile"{
 type = string
}

variable "zone_name" {
    type = string
}

variable "site_name" {
    type = string
}

variable "inst_name" {
    type = string
}

variable "lb_name" {
    type = string
}
variable "tg_name" {
    type = string
}

variable "port" {
    type = string
}

variable "vpc_id" {
    type = string
}