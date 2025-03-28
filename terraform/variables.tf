variable "rekog_project_arn" {
    description = "Amazon Rekognition Project ARN that labels images"
    type        = string
    sensitive   = true
}

variable "dynamodb_table_arn" {
    description = "Dynamo DB Table ARN that stores Rekognition's results"
    type        = string
    sensitive   = true
}

variable "s3_bucket_arn" {
    description = "S3 Bucket ARN that stores the users' images"
    type        = string
    sensitive   = true
}

variable "sqs_queue_arn" {
    description = "SQS Queue ARN that sends messages to the Cat Sender Lambda"
    type        = string
    sensitive   = true
}
