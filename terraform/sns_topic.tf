resource "aws_sns_topic" "notification_topic" {
  name = "image-upload-topic"
  fifo_topic = false 
}

resource "aws_sns_topic_policy" "sns_allow_s3_access" {
  arn = aws_sns_topic.notification_topic.arn
  policy = data.aws_iam_policy_document.sns_s3_policy_document.json
}

data "aws_iam_policy_document" "sns_s3_policy_document" {
  version = "2012-10-17"

  statement {
    actions = [ "SNS:Publish" ]

    condition {
      test = "StringEquals"
      variable = "aws:SourceAccount"

      values = [
        var.account_id
      ]
    }

    condition {
      test = "ARNLike"
      variable = "aws:SourceArn"

      values = [
        aws_s3_bucket.s3.arn
      ]
    }

    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    resources = [ aws_sns_topic.notification_topic.arn ]
  }
}