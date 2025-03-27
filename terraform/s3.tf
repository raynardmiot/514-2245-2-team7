resource "aws_s3_bucket" "s3" {
	bucket = "swen-514-7-image-bucket"
}

resource "aws_s3_bucket_policy" "allow_access_from_other_services" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.allow_access_from_other_services.json
}