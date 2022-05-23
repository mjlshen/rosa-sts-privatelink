provider "aws" {
  region  = "us-east-2"
  profile = "osd-staging-2"
  assume_role {
    role_arn = "arn:aws:iam::429297027867:role/OrganizationAccountAccessRole"
  }

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
