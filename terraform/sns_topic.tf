resource "aws_sns_topic" "notification_topic" {
  name = "get-results-topic"
  fifo_topic = false 
}