variable "region" {
    default = "us-west-1"
}
variable "policy" {
    type        = string
    description = "Ingrese permisos a otorgar Ejm: lectura = policy_ro.tpl | lectura/escritura policy_rw.tpl | lectura/escritura/delete policy_rwd.tpl"
    default = "policy_ro.tpl"
}
variable "bucket_name" {
    type = string
}
variable "user_name" {
    type = string
}
# Si necesitamos usar profiles descomentar las siguientes lineas.
#variable "profile"{
# type = string
#}
