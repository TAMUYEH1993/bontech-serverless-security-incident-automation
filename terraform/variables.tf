variable "alert_email" {
  description = "Email address used for SNS security alert notifications"
  type        = string
  sensitive   = true
}