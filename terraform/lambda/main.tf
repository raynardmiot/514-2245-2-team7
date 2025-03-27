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
                "Resource": "arn:aws:dynamodb:us-east-1:699475959125:table/CatImageLabels"
            },
            {
                "Effect": "Allow",
                "Action": "rekognition:DetectCustomLabels",
                "Resource": "arn:aws:rekognition:us-east-1:699475959125:project/cat-subreddit-discovery-system/version/cat-subreddit-discovery-system.2025-03-25T00.21.11/1742876471796"
            },
            {
                "Effect": "Allow",
                "Action": "s3:GetObject",
                "Resource": [
                    "arn:aws:s3:::514-test-cats-bucket",
                    "arn:aws:s3:::514-test-cats-bucket/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "sqs:ReceiveMessage",
                    "sqs:DeleteMessage",
                    "sqs:GetQueueAttributes"
                ],
                "Resource": "*" // Change to actual SQS queue ARN later
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
}