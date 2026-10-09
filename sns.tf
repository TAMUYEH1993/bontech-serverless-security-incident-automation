# SNS topic used to send security incident alerts
resource "aws_sns_topic" "security_alerts" {
  name = "BonTech-Terraform-Security-Alerts"

  tags = {
    ManagedBy = "Terraform"
    Project   = "BonTech-Serverless-Security"
  }
}

# Email subscription for security alerts
resource "aws_sns_topic_subscription" "security_alert_email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint = var.alert_email
}