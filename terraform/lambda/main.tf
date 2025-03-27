terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = file("${path.module}/../config/aws_region")
}

# IAM Role for the Lambda
resource "aws_iam_role" "cat_sender_iam_role" {
    name = "CatSenderAssumeRole"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
        }]
    })
}

# IAM Policies for the Lambda
resource "aws_iam_policy" "cat_sender_iam_policy" {
    name = "CatSenderIAMPolicy" 
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": "dynamodb:PutItem",
                "Resource": var.dynamodb_table_arn
            },
            {
                "Effect": "Allow",
                "Action": "rekognition:DetectCustomLabels",
                "Resource": var.rekog_project_arn
            },
            {
                "Effect": "Allow",
                "Action": "s3:GetObject",
                "Resource": [
                    var.s3_bucket_arn,
                    var.s3_bucket_arn + "/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "sqs:ReceiveMessage",
                    "sqs:DeleteMessage",
                    "sqs:GetQueueAttributes"
                ],
                "Resource": var.sqs_queue_arn
            }
        ]
    })
}

# Attach IAM policy to IAM role
resource "aws_iam_role_policy_attachment" "attachment" {
    role       = aws_iam_role.cat_sender_iam_role.name
    policy_arn = aws_iam_policy.cat_sender_iam_policy.name 
}

# ZIP the Python code
data "archive_file" "output" {
    type        = "zip"
    source_file = "${path.module}/lambda_functions/cat_sender.py"
    output_path = "${path.module}/out/cat_sender.zip"
}

# Now create the actual Lambda
resource "aws_lambda_function" "cat_sender_lambda" {
    filename         = data.archive_file.output.output_path
    function_name    = "CatSender"
    role             = aws_iam_role.cat_sender_iam_role.arn
    handler          = "cat_sender.lambda_handler"
    source_code_hash = data.archive_file.output.output_base64sha256
    runtime          = "python3.11"

    environment {
        variables = {
            REKOG_PROJECT_ARN = var.rekog_project_arn
        }
    }
}