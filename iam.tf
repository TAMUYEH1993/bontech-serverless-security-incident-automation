resource "aws_iam_role" "lambda_execution_role" {
  name = "BonTech-Terraform-Lambda-Execution-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    ManagedBy = "Terraform"
    Project   = "BonTech-Serverless-Security"
  }
}

# Allows the Lambda function to write execution logs to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_basic_logging" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Allows the Lambda function to write security incidents
# only to the Terraform-managed DynamoDB table
resource "aws_iam_role_policy" "lambda_dynamodb_write" {
  name = "BonTech-Terraform-Lambda-DynamoDB-Write"

  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "dynamodb:PutItem"
        ]

        Resource = aws_dynamodb_table.security_incidents.arn
      }
    ]
  })
}

# Allows the Lambda function to publish security alerts
# only to the Terraform-managed SNS topic
resource "aws_iam_role_policy" "lambda_sns_publish" {
  name = "BonTech-Terraform-Lambda-SNS-Publish"

  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sns:Publish"
        ]

        Resource = aws_sns_topic.security_alerts.arn
      }
    ]
  })
}