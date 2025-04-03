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
                "Resource": aws_dynamodb_table.labels_table.arn
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
                    aws_s3_bucket.s3.arn,
                    "${aws_s3_bucket.s3.arn}/*"
                ]
            },
            {
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Effect": "Allow",
                "Resource": "arn:aws:logs:*:*:*"
            }
        ]
    })
}

# Attach IAM policy to IAM role
resource "aws_iam_role_policy_attachment" "attachment" {
    role       = aws_iam_role.cat_sender_iam_role.name
    policy_arn = aws_iam_policy.cat_sender_iam_policy.arn
}

# ZIP the Python code
data "archive_file" "output" {
    type        = "zip"
    source_file = "${path.module}/dependencies/cat_sender.py"
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
    layers           = [ aws_lambda_layer_version.python_modules.id ]

    timeout          = 10

    environment {
        variables = {
            REKOG_PROJECT_ARN = var.rekog_project_arn
            DYNAMODB_TABLE_ARN = aws_dynamodb_table.labels_table.arn
        }
    }
}

// SNS trigger for Lambda
resource "aws_lambda_permission" "sns_trigger" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cat_sender_lambda.function_name
  principal = "sns.amazonaws.com"
  source_arn = aws_sns_topic.notification_topic.arn
}

// Layer to allow Lambda to use Python requests module
resource "aws_lambda_layer_version" "python_modules" {
  filename = "dependencies/python_modules.zip"
  layer_name = "python-modules"

  compatible_runtimes = [ "python3.11", "python3.12", "python3.13" ]
}