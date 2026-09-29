# Day 2 Evidence

Day 2 demonstrates the live event-driven path from sensitive IAM activity to automated incident persistence.

## Recommended sanitized screenshots

| File | What it demonstrates |
|---|---|
| `01-eventbridge-rule-pattern.png` | EventBridge rule pattern detecting sensitive IAM API calls. |
| `02-eventbridge-lambda-target.png` | Lambda configured as the rule target with the matched event forwarded. |
| `03-lambda-resource-policy.png` | Scoped resource-based permission allowing EventBridge to invoke Lambda. |
| `04-cloudtrail-audit-trail.png` | `BonTech-Security-Audit-Trail` logging write management events. |
| `05-cloudtrail-deletepolicy-event.png` | Real `DeletePolicy` management event recorded by CloudTrail. |
| `06-eventbridge-success-metrics.png` | MatchedEvents, TriggeredRules, and Invocations confirming rule execution. |
| `07-lambda-success-metrics.png` | Lambda invocation with 100% success and zero errors. |
| `08-cloudwatch-deletepolicy-logs.png` | Lambda processing `DeletePolicy` and confirming DynamoDB storage. |
| `09-dynamodb-live-incident.png` | Final incident table containing the automatically generated `DeletePolicy` incident. |

## Sanitization checklist

Before uploading screenshots publicly, redact:

- AWS account ID in the console header
- Account IDs embedded in ARNs
- Access keys, secret keys, session tokens, or credentials if ever visible
- Request/principal identifiers when they add no portfolio value
- Source IP addresses or other unnecessary account-specific metadata

Keep project resource names, event names, severity, incident status, and architecture-relevant fields visible.

## Evidence chain

```text
IAM DeletePolicy
      ↓
CloudTrail
      ↓
EventBridge MatchedEvents = 1
      ↓
TriggeredRules = 1
      ↓
Invocations = 1
      ↓
Lambda success = 100%
      ↓
CloudWatch: DeletePolicy / HIGH / OPEN
      ↓
DynamoDB: generated incident stored
```

## Result

The evidence demonstrates that Day 2 progressed beyond a synthetic Lambda test to a live AWS control-plane security event processed through the complete serverless detection pipeline.
