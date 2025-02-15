terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "~> 3.38"
      version = "5.64.0"
    }

  }
  required_version = "~> 1.9"

  backend "s3" {
    bucket = "comet-terraform-state-us-east-1"
    key    = "parent/terraform.tfstate"
    region = "us-east-1"

  }
}

provider "aws" {

  region = "us-east-1"
  default_tags {
    tags = {
      #   environment = "global"
      contact = "devops@icf.com"
      project = "comet"
    }
  }

}