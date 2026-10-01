# Day 3 Evidence – Automated Security Alerting with Amazon SNS

This folder contains sanitized evidence demonstrating the implementation and validation of automated security incident notifications using Amazon SNS.

## Evidence

1. Amazon SNS security alerts topic and confirmed subscription
2. Lambda IAM least-privilege SNS publish permission
3. Lambda Python/Boto3 SNS integration
4. Successful Lambda execution
5. DynamoDB incident record
6. CloudWatch execution logs
7. Automated security alert delivered by email

## Validated Workflow

CloudTrail → EventBridge → Lambda → DynamoDB → SNS → Security Analyst Email

CloudWatch provides logging and operational visibility throughout the Lambda processing workflow.

## Security Note

Sensitive information such as AWS account IDs, personal email addresses, ARNs containing account identifiers, and SNS subscription URLs has been redacted from public screenshots.
