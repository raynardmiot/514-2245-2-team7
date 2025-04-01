resource "aws_s3_bucket" "s3" {
	bucket = "swen-514-7-image-bucket-with-unique-name-2"
}

resource "aws_s3_bucket_policy" "allow_access_from_other_services" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.allow_access_from_other_services.json
}

resource "aws_s3_bucket_notification" "image_upload_notification" {
  bucket = aws_s3_bucket.s3.id

  // IMPORTANT! makes sure that the S3 notification event is created AFTER the SNS topic config is
  // created and the bucket is allowed to communicate with other services - avoids error "Unable
  // to validate the following destination configurations"
  depends_on = [
    aws_sns_topic.notification_topic,
    aws_sns_topic_policy.sns_allow_s3_access,
    aws_s3_bucket_policy.allow_access_from_other_services
  ]

  topic {
    topic_arn = aws_sns_topic.notification_topic.arn
    events = [ "s3:ObjectCreated:*" ]
  }
}