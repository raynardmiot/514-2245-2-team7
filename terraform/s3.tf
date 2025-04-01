resource "aws_s3_bucket" "s3" {
	bucket = "swen-514-7-image-bucket-with-unique-name"
  force_destroy = true  // destroy even if there are files in the bucket
}

resource "aws_s3_bucket_policy" "allow_access_from_other_services" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.allow_access_from_other_services.json
}

resource "aws_s3_bucket_notification" "s3_to_lambda_notification" {
  bucket = aws_s3_bucket.s3.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.cat_sender_lambda.arn
    events = [ "s3:ObjectCreated:*" ]
  }
}