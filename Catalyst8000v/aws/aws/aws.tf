provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "your_profile"
  region                   = var.region
}
