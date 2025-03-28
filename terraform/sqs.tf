resource "aws_sqs_queue" "notification_queue" {
  name = "upload-notification-queue"
  sqs_managed_sse_enabled = true 
}

resource "aws_sns_topic_subscription" "sns_upload_subscription" {
  topic_arn = aws_sns_topic.notification_topic.arn
  protocol = "sqs"
  endpoint = aws_sqs_queue.notification_queue.arn
}