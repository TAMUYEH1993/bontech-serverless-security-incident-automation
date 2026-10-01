# Day 1 Evidence

Day 1 establishes the serverless incident-processing foundation: Lambda/Python/Boto3 writes structured security incidents to DynamoDB under least-privilege IAM permissions, with CloudWatch providing operational visibility.

## Published sanitized evidence

| File | What it demonstrates |
|---|---|
| `01-iam-dynamodb-least-privilege-policy.png` | Lambda execution authorization scoped to the DynamoDB incident workflow. |
| `02-lambda-incident-processor-code.png` | Python/Boto3 incident-processing logic used by `BonTech-Incident-Processor`. |
| `03-dynamodb-inc-002-record.png` | `INC-002` persisted in `BonTech-Security-Incidents` after Lambda processing. |
| `04-cloudwatch-successful-incident-processing.png` | CloudWatch application logs confirming successful incident processing and DynamoDB storage. |
| `05-dynamodb-table-initial-incident-record.png` | DynamoDB incident table and the initial baseline incident data used to establish the schema. |
| `06-lambda-deployed-incident-processor.png` | The deployed `BonTech-Incident-Processor` Lambda implementation in AWS. |

## Evidence chain

```text
DynamoDB incident foundation
          ↓
AWS Lambda (Python/Boto3)
          ↓
IAM least-privilege authorization
          ↓
DynamoDB PutItem
          ↓
Incident persisted
          ↓
CloudWatch validation
```

## Result

The evidence demonstrates that the Day 1 Lambda could process an incident, use its scoped IAM permissions to write the incident to DynamoDB, and produce operational logs confirming successful processing.

## Security / Sanitization

The published screenshots were prepared for portfolio use with unnecessary account-identifying information redacted. Credentials, access keys, secret keys, session tokens, and other authentication material must never be published.
