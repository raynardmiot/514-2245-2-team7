resource "aws_s3_bucket" "s3" {
	bucket = "swen-514-7-image-bucket-with-unique-name-abc"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "allow_access_from_other_services" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.allow_access_from_other_services.json
}

resource "aws_s3_bucket_notification" "s3_to_sns_notification" {
  bucket = aws_s3_bucket.s3.id

  topic {
    topic_arn = aws_sns_topic.notification_topic.arn
    events = [ "s3:ObjectCreated:*" ]
  }

  // Don't delete, this keeps the S3 event from being created BEFORE the SNS policy
  // and ruining everything
  depends_on = [ 
    aws_sns_topic.notification_topic, 
    aws_sns_topic_policy.access_s3_policy,
    data.aws_iam_policy_document.sns_topic_policy
  ]
}