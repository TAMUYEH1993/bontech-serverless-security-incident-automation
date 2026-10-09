# Creates the Lambda function for processing security incidents
resource "aws_lambda_function" "incident_processor" {

  function_name = "BonTech-Terraform-Incident-Processor"

  role = aws_iam_role.lambda_execution_role.arn

  runtime = "python3.12"

  handler = "lambda_function.lambda_handler"

  filename = "lambda_function.zip"

  source_code_hash = filebase64sha256("lambda_function.zip")

  timeout = 10

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.security_incidents.name
      SNS_TOPIC_ARN  = aws_sns_topic.security_alerts.arn
    }
  }

  tags = {
    ManagedBy = "Terraform"
    Project   = "BonTech-Serverless-Security"
  }
}