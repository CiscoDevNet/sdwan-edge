variable "name" {}

variable "region" {}
variable "availability_zone" {}

variable "subnet_name_prefix" { default = "subnet" }
variable "address_space" { default = "10.0.0.0/16" }
variable "subnet_transport_prefix" { default = "10.0.1.0/24" }
variable "subnet_service_prefix" { default = "10.0.2.0/24" }
