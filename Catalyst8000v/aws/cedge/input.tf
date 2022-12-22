
variable "name" {}

variable "region" {}
variable "vpc_id" {}

variable "subnet_transport" {}
variable "subnet_service" {}

variable "image_id" {}
variable "instance_type" {}

variable "route53_zone" {
  default = ""
}
