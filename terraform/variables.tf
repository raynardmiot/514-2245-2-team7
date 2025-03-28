variable "aws_key" {
    description = "AWS key ID for your local account, dev purposes only"
    type        = string
    sensitive   = true
}

variable "aws_secret" {
    description = "AWS secret key for your local account, dev purposes only"
    type        = string
    sensitive   = true
}

variable "aws_region" {
    description = "AWS secret key for your local account, dev purposes only"
    type        = string
    default = "us-east-1"
}

variable "rekog_project_arn" {
    description = "Amazon Rekognition Project ARN that labels images"
    type        = string
    sensitive   = true
}

variable "account_id" {
  type    = string
  sensitive = true
}