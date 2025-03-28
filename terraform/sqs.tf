resource "aws_sqs_queue" "sqs" {
  name                      = "cassydi-sqs"
}

resource "aws_sns_topic_subscription" "sns_to_sqs" {
  topic_arn = aws_sns_topic.sns.arn  # TODO: Reference SNS topic ARN
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sqs.arn
}