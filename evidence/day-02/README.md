# Day 2 Evidence

Day 2 extends the Day 1 foundation into event-driven security detection and validates Lambda execution, CloudWatch observability, and automated incident persistence in DynamoDB.

## Published sanitized evidence

| File | What it demonstrates |
|---|---|
| `01-lambda-successful-execution.png` | Successful Lambda execution during Day 2 validation. |
| `02-lambda-cloudwatch-success-metrics.png` | Lambda/CloudWatch operational metrics showing successful function activity. |
| `03-cloudwatch-lambda-log-group.png` | The CloudWatch log group used for the incident processor. |
| `04-cloudwatch-lambda-execution-log.png` | Lambda execution records captured in CloudWatch. |
| `05-cloudwatch-incident-processing-validation.png` | Application-level CloudWatch evidence showing the security incident being processed and persisted. |
| `06-dynamodb-generated-incident-record.png` | Automatically generated incident record stored in DynamoDB. |

## Day 2 architecture

```text
Sensitive IAM activity
      ↓
CloudTrail
      ↓
EventBridge
      ↓
Lambda
      ├──→ CloudWatch
      └──→ DynamoDB
```

The complete Day 2 implementation, including the EventBridge rule, CloudTrail write-management-event trail, scoped EventBridge-to-Lambda invocation permission, and live `DeletePolicy` validation, is documented in [Day 2 documentation](../../docs/day-02.md).

## Result

The published evidence supports the Day 2 transition from a manually tested serverless processor to the event-driven incident-processing workflow. The detailed Day 2 documentation records the additional control-plane configuration and live IAM `DeletePolicy` validation.

## Security / Sanitization

The published screenshots were prepared for portfolio use with unnecessary account-identifying information redacted. Credentials, access keys, secret keys, session tokens, and other authentication material must never be published.
