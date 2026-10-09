# Detect sensitive IAM activity using EventBridge
resource "aws_cloudwatch_event_rule" "sensitive_iam_activity" {
  name        = "BonTech-Terraform-Sensitive-IAM-Activity"
  description = "Detects sensitive IAM API activity recorded by CloudTrail"

  event_pattern = jsonencode({
    source      = ["aws.iam"]
    detail-type = ["AWS API Call via CloudTrail"]

    detail = {
      eventSource = ["iam.amazonaws.com"]

      eventName = [
        "AttachUserPolicy",
        "PutUserPolicy",
        "CreatePolicy",
        "DeletePolicy"
      ]
    }
  })

  tags = {
    ManagedBy = "Terraform"
    Project   = "BonTech-Serverless-Security"
  }
}

# Send matching EventBridge events to the incident processor Lambda
resource "aws_cloudwatch_event_target" "incident_processor" {
  rule      = aws_cloudwatch_event_rule.sensitive_iam_activity.name
  target_id = "BonTech-Terraform-Incident-Processor"
  arn       = aws_lambda_function.incident_processor.arn
}

# Allow only this EventBridge rule to invoke the Lambda function
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.incident_processor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sensitive_iam_activity.arn
}