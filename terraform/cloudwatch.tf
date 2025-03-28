resource "aws_cloudwatch_log_group" "log_group" {
    name = "cassydi-log-group"
    retention_in_days = 7
}