terraform {
  cloud {
    organization = "nhakobyan685"
    workspaces {
      name = "s3_destroy"
    }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.54.0"
    }
  }
}
