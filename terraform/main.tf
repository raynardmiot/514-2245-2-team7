terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
	access_key = var.aws_key
	secret_key = var.aws_secret
}