provider "aws" {
  region = "us-east-2"

  default_tags {
    tags = {
      owner = "terraform"
    }
  }
}

module "rosa_sts_privatelink_networking" {
  source = "../"

  name     = "rosa-sts-pl"
  cidr     = "10.0.0.0/16"
  multi_az = false
}

output "private_subnet_ids" {
  value = module.rosa_sts_privatelink_networking.private_subnet_ids
}
