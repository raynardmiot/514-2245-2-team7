# Development README

Terraform needs AWS credentials to work, as well as the pre-created Rekognition project ARN.

You will need to copy the Rekognition model to your AWS account, since Rekognition does not allow
for direct cross-account access :(

To run the Terraform setup locally on your AWS account, create a `terraform.tfvars` file here in
the `terraform` directory, then enter the following into the file:

```
aws_key = "<your key ID>"
aws_secret = "<your secret key>"
rekog_project_arn = "<ARN of the Rekognition project copy>"
account_id = "<your account ID>"
```

This is for development purposes only - in "production" we will have the AWS credentials
configured through the AWS CLI, which should be installed on the AMI.