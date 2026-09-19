# Day 1 Evidence

Day 1 evidence was reviewed before publication. AWS account-specific identifiers should be redacted from public screenshots.

## Evidence prepared

| File | What it demonstrates |
|---|---|
| `01-dynamodb-table-created.png` | The `BonTech-Security-Incidents` DynamoDB table was successfully created with `incident_id` as the partition key. |
| `02-dynamodb-inc001.png` | Baseline security incident `INC-001` stored with event type, description, severity, source, and status attributes. |
| `03-lambda-python-creation.png` | Creation of the `BonTech-Incident-Processor` Lambda function using Python 3.14. |
| `04-lambda-test-event.png` | Lambda test configuration used to validate the Lambda-to-DynamoDB connection. |
| `05-cloudwatch-success-logs.png` | CloudWatch application logs showing `INC-002` processing and successful DynamoDB storage. |

## Security / Sanitization

Public evidence should not expose unnecessary AWS account IDs, account aliases, credentials, access keys, tokens, or account-specific ARNs. Screenshots containing account-specific identifiers were redacted before being prepared for publication.

## What the evidence proves

Together, these artifacts document the Day 1 path:

```text
DynamoDB table + incident schema
          ↓
AWS Lambda (Python)
          ↓
Boto3 / DynamoDB PutItem
          ↓
IAM authorization
          ↓
Incident stored
          ↓
CloudWatch application logs
```

The final CloudWatch evidence records the application messages for processing `INC-002` and successfully storing the incident in DynamoDB.
