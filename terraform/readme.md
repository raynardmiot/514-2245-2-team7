# Development README

Terraform needs AWS credentials to work. To run these Terraform instances locally, add 
two files - `aws_key` and `aws_secret` to the `config` directory. Create an access key 
under **(your account) > Security credentials** and paste in the AWS key ID and AWS key
secret into their respective files. Do not paste anything else into the files.

This is for development purposes only - in "production" we will have the AWS credentials
configured through the AWS CLI, which should be installed on the AMI.