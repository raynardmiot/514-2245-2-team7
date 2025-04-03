resource "aws_sns_topic" "notification_topic" {
  name = "upload-image-topic"
  fifo_topic = false 
}

resource "aws_sns_topic_policy" "access_s3_policy" {
  policy = data.aws_iam_policy_document.sns_topic_policy.json
  arn = aws_sns_topic.notification_topic.arn
}

resource "aws_sns_topic_subscription" "lambda_subscription" {
  protocol = "lambda"
  topic_arn = aws_sns_topic.notification_topic.arn
  endpoint = aws_lambda_function.cat_sender_lambda.arn
}

// Pretty open policy for SNS but this makes the S3 work nicely with it
// Real-world application would probably use more restrictive policy
data "aws_iam_policy_document" "sns_topic_policy" {
  version = "2008-10-17"
  policy_id = "__default_policy_ID"
  
  statement {
    actions = [
      "SNS:Publish",
      "SNS:RemovePermission",
      "SNS:SetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:AddPermission",
      "SNS:Subscribe"
    ]

    sid = "__default_statement_ID"
    effect = "Allow"
    principals {
      identifiers = [ "*" ]
      type = "AWS"
    }

    resources = [ aws_sns_topic.notification_topic.arn ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.account_id,
      ]
    }
  }

  statement {
    sid = "__console_pub_0"
    effect = "Allow"
    principals {
      identifiers = [ "*" ]
      type = "AWS"
    }

    actions = [ "SNS:Publish" ]
    resources = [ aws_sns_topic.notification_topic.arn ]
  }
}