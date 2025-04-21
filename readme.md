# CASSYDI

Don't know which subreddit to upload your cat picture to? This app can help!

### Cloning the repo

Enter the desired directory on your machine and clone the repo with
`git clone https://github.com/raynardmiot/514-2245-2-team7.git`

### Terraform setup

Terraform needs AWS credentials to provision resources on an account. It also needs a unique S3 bucket name, since buckets are part of a global namespace. These properties can be configured by creating a `terraform.tfvars` file in the `terraform/` directory. Add the following content to the file:

```
aws_key = "your AWS access key ID, e.g. AKIAIOSFODNN7EXAMPLE"
aws_secret = "your AWS secret access key, e.g. wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
account_id = "your 12 digit account ID"
s3_bucket_name = "something unique like swen-514-7-image-bucket-abcd1234"
```

> For information about AWS access keys, see [this AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id-credentials-access-keys-update.html).

Once you have everything configured, in the `terraform/` directory run `terraform init`, `terraform plan`, and `terraform apply` to start the app. Type `yes` whenever Terraform prompts you to do so. Terraform will output the URL to the frontend of the app, hosted on the EC2.

> **NOTE:** Before running the app, contact Raynard and tell him to start the Rekognition model. Rekognition doesn't work well with Terraform since it takes a while to re-train the model, so our app calls a pre-existing API hosted on Raynard's account to get image results. Rekognition is also very expensive to keep running in the background, so it is turned off by default.

### Uploading an image

Visit the webpage linked by Terraform's output. You should have a prompt to upload an image. Our app accepts `.jpg` and `.jpeg` formatted images. After a short wait upon uploading, the results will be displayed on the webpage.

### Cleanup

Run `terraform destroy` in the `terraform/` directory to destroy all resources. Type `yes` when prompted.

> **NOTE:** Be sure to contact Raynard and tell him to stop the Rekognition model to avoid any additional cost.