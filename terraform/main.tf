terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = file("${path.module}/config/aws_region")
	access_key = file("${path.module}/config/aws_key")
	secret_key = file("${path.module}/config/aws_secret")
}