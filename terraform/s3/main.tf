terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = "us-east-2"
    profile = "testing"

    # if you want to do this locally, create a credentials file as listed in this stackoverflow page:
    # https://stackoverflow.com/questions/36990299/terraform-aws-credentials-file-not-found
    # in the final version we will have the AMI configured to already use someone's credentials, so this will be removed
    shared_credentials_files = [ "/home/dan/.aws" ]
}

resource "aws_s3_bucket" "cassydi_s3" {
    bucket = "swen-514-team-7-image-bucket"
}