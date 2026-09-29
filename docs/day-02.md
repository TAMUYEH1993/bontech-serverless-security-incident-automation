# Day 2 — Event-Driven IAM Security Detection

## Objective

Convert the Day 1 Lambda-to-DynamoDB foundation into a live event-driven detection pipeline for sensitive IAM policy changes.

## Architecture

```text
Sensitive IAM API activity
        |
        v
AWS CloudTrail
(write management events)
        |
        v
Amazon EventBridge
BonTech-Sensitive-IAM-Activity-Detection
        |
        v
AWS Lambda
BonTech-Incident-Processor
        |
        +--> DynamoDB incident record
        |
        +--> CloudWatch application logs
```

## Detection Scope

The EventBridge rule detects CloudTrail API calls for:

- `AttachUserPolicy`
- `PutUserPolicy`
- `CreatePolicy`
- `DeletePolicy`

## CloudTrail Configuration

Created `BonTech-Security-Audit-Trail` with logging enabled. The trail records **write management events**. Data events, Insights events, network activity events, SNS delivery, and CloudWatch Logs delivery were not required for this detection path.

## EventBridge Configuration

Rule: `BonTech-Sensitive-IAM-Activity-Detection`

```json
{
  "source": ["aws.iam"],
  "detail-type": ["AWS API Call via CloudTrail"],
  "detail": {
    "eventSource": ["iam.amazonaws.com"],
    "eventName": [
      "AttachUserPolicy",
      "PutUserPolicy",
      "CreatePolicy",
      "DeletePolicy"
    ]
  }
}
```

The rule targets `BonTech-Incident-Processor` and forwards the matched event.

## Lambda Invocation Permission

The Lambda resource-based policy grants `events.amazonaws.com` permission to invoke the function and scopes the permission to the EventBridge rule ARN.

This is separate from the Lambda execution role: the resource policy controls **who can invoke Lambda**, while the execution role controls **what Lambda can do after it starts**.

## Dynamic Incident Processing

The Day 2 Lambda reads the EventBridge/CloudTrail event, extracts the IAM API event name, generates a unique incident ID, assigns security metadata, writes the incident to DynamoDB, and records processing details in CloudWatch.

## Live End-to-End Test

A harmless customer-managed test policy was deleted to generate a real `DeletePolicy` API call.

Verification showed:

1. CloudTrail Event History recorded `DeletePolicy`.
2. EventBridge reported one matched event.
3. EventBridge reported one triggered rule and one invocation.
4. No failed EventBridge invocation was shown.
5. Lambda recorded one invocation with 100% success and zero errors.
6. CloudWatch logged `Event: DeletePolicy | Severity: HIGH | Status: OPEN`.
7. CloudWatch confirmed the generated incident was successfully stored in DynamoDB.
8. DynamoDB returned five total incident records, including the new live `DeletePolicy` incident.

## Troubleshooting Lessons

Two configuration gaps were identified during validation:

### EventBridge could not invoke Lambda

The Lambda resource-based policy initially had no statement permitting EventBridge invocation. A scoped `lambda:InvokeFunction` permission was added for the EventBridge rule.

### CloudTrail API-call delivery path was incomplete

CloudTrail Event History showed IAM activity, but EventBridge had no matched-event metrics. A logging trail was created for write management events. After the trail was active, a fresh `DeletePolicy` event matched the EventBridge rule and successfully invoked Lambda.

## Security Engineering Takeaways

- Use least privilege for both Lambda execution permissions and invocation permissions.
- Detect high-value IAM control-plane changes rather than collecting unrelated events for the use case.
- Validate every stage of an event-driven pipeline independently.
- CloudWatch metrics and application logs are essential for distinguishing event matching, invocation, execution, and downstream persistence problems.
- Use harmless, purpose-built test resources when validating detections.

## Day 2 Result

**SUCCESS:** A real IAM `DeletePolicy` action flowed through CloudTrail and EventBridge, invoked Lambda, was processed as a HIGH-severity OPEN incident, and was persisted in DynamoDB with CloudWatch evidence.
