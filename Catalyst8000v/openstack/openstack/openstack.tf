terraform {
 required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.47.0"
    }
  }
}

provider "openstack" {
  user_name   = ""
  tenant_name = ""
  password    = ""
  auth_url    = "http://1.2.3.4:5000/v2.0"
  region      = "RegionOne"
}
