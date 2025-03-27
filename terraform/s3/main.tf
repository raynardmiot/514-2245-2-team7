terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = file("${path.module}/../config/aws_region")
    access_key = file("${path.module}/../config/aws_key")
    secret_key = file("${path.module}/../config/aws_secret")
}

resource "aws_s3_bucket" "s3" {
    bucket = "swen-514-7-image-bucket"
}