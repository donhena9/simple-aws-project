resource "aws_cloudwatch_log_group" "httpbin_log_group" {
  name              = "/ecs/httpbin-log-group"
  retention_in_days = var.retention_in_days
}