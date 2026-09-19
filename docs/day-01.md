# Day 1 — Serverless Incident Processing Foundation

## Objective

Establish the first working path of the BonTech serverless security incident automation platform and verify that a Lambda function can securely persist an incident in DynamoDB while producing useful CloudWatch logs.

## Resources Created

- DynamoDB table: `BonTech-Security-Incidents`
- Lambda function: `BonTech-Incident-Processor`
- Lambda execution role with CloudWatch logging permissions
- Least-privilege DynamoDB permission allowing `dynamodb:PutItem` on the project table

## Hands-on Workflow

### 1. DynamoDB foundation

Created a DynamoDB table to serve as the incident store. A manual baseline incident (`INC-001`) was used to validate the schema.

### 2. Lambda and Boto3

Created a Python Lambda function and used Boto3 to obtain a DynamoDB resource and reference the incident table.

### 3. IAM least privilege

Instead of attaching broad DynamoDB permissions, the Lambda execution role was restricted to `dynamodb:PutItem` for the specific incident table.

This demonstrates both **action-level** and **resource-level** least privilege.

### 4. Programmatic incident creation

The Lambda function created `INC-002` with the following security metadata:

- Event type: `UnauthorizedAccess`
- Severity: `HIGH`
- Status: `OPEN`
- Source: `AWS`
- Description: `Unauthorized access attempt detected`

### 5. End-to-end validation

The Lambda test completed successfully and `INC-002` appeared in DynamoDB. This validated the relationship between Python, Boto3, the DynamoDB API, IAM authorization, and DynamoDB storage.

### 6. CloudWatch observability

Added Python logging to record the incident being processed and confirmation of successful storage. CloudWatch showed the custom application logs together with the Lambda `START`, `END`, and `REPORT` lifecycle records.

## Key Learning

```text
Python = programming language
Boto3 = AWS SDK for Python
PutItem = DynamoDB API operation
IAM = authorization decision
DynamoDB = incident persistence
CloudWatch = operational visibility
```

The Python code can request an AWS operation through Boto3, but the Lambda execution role determines whether AWS authorizes that operation.

## Real-World Cloud Security / SOC Relevance

This pattern mirrors a common security automation workflow: a security event is received by serverless compute, enriched or processed, written to an incident store, and logged for investigation and troubleshooting. Later project phases will replace the manual test event with event-driven ingestion and add notification and response components.

## Day 1 Result

**SUCCESS:** Lambda executed, IAM authorized the scoped DynamoDB write, `INC-002` was stored, and CloudWatch captured the processing logs.

## Evidence Checklist

The following screenshots were captured during the lab and should be sanitized before public upload:

- IAM policy showing `dynamodb:PutItem` scoped to the incident table
- IAM JSON policy with account-specific identifiers redacted
- Lambda code/deployment success
- Lambda test execution success
- DynamoDB showing `INC-001` and `INC-002`
- Lambda CloudWatch metrics
- CloudWatch application logs showing incident processing and successful DynamoDB storage
