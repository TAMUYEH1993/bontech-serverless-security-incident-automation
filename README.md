# BonTech AWS Serverless Security Incident Automation

A hands-on AWS cloud security engineering project building a serverless security incident automation platform with **CloudTrail, EventBridge, AWS Lambda, Python/Boto3, DynamoDB, IAM least privilege, and CloudWatch**.

> **Project status:** Day 2 completed — live event-driven IAM security detection validated end-to-end.

## Project Goal

Build a security automation workflow that detects sensitive AWS activity, processes it with serverless Python, persists structured incidents, and provides operational evidence for investigation and troubleshooting.

## Current Architecture

```text
Sensitive IAM API activity
        |
        v
AWS CloudTrail
(write management events)
        |
        v
Amazon EventBridge
        |
        v
AWS Lambda (Python/Boto3)
        |
        +------> DynamoDB (incident record)
        |
        +------> CloudWatch Logs

Future phases:
        +------> SNS alerting
        +------> Automated response
        +------> API Gateway
        +------> Terraform
```

## Day 1 — Serverless Incident Processing Foundation

- Created `BonTech-Security-Incidents` DynamoDB table.
- Created `BonTech-Incident-Processor` Lambda using Python/Boto3.
- Scoped the Lambda execution role to `dynamodb:PutItem` on the project table.
- Validated Lambda-to-DynamoDB persistence.
- Added CloudWatch application logging.

See [Day 1 documentation](docs/day-01.md).

## Day 2 — Event-Driven IAM Security Detection

- Created EventBridge rule `BonTech-Sensitive-IAM-Activity-Detection`.
- Detects `AttachUserPolicy`, `PutUserPolicy`, `CreatePolicy`, and `DeletePolicy` CloudTrail API calls.
- Created `BonTech-Security-Audit-Trail` for write management events.
- Added a scoped Lambda resource-based permission for EventBridge invocation.
- Updated Lambda for dynamic EventBridge/CloudTrail event processing.
- Performed a live `DeletePolicy` test.
- Verified EventBridge MatchedEvents, TriggeredRules, and Invocations.
- Verified Lambda 100% success with zero errors.
- Verified CloudWatch processing logs.
- Verified the generated HIGH-severity OPEN incident in DynamoDB.

See [Day 2 documentation](docs/day-02.md).

## Detection Pattern

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

## Security Design

### Lambda execution authorization

The Lambda execution role uses least privilege and permits only the DynamoDB operation required by the function:

```json
{
  "Effect": "Allow",
  "Action": "dynamodb:PutItem",
  "Resource": "arn:aws:dynamodb:us-east-1:<ACCOUNT-ID>:table/BonTech-Security-Incidents"
}
```

### Lambda invocation authorization

A separate Lambda resource-based policy allows `events.amazonaws.com` to invoke the function and restricts the permission to the project's EventBridge rule ARN.

This separates **who can invoke the function** from **what the function can do**.

## Live Day 2 Validation

The live validation produced this chain:

```text
IAM DeletePolicy
      ↓
CloudTrail recorded the write management event
      ↓
EventBridge MatchedEvents = 1
      ↓
TriggeredRules = 1
      ↓
Invocations = 1
      ↓
Lambda invocation succeeded
      ↓
CloudWatch logged DeletePolicy / HIGH / OPEN
      ↓
DynamoDB stored the generated incident
```

## Repository Structure

```text
.
├── README.md
├── lambda/
│   └── incident_processor.py
├── docs/
│   ├── day-01.md
│   └── day-02.md
└── evidence/
    ├── day-01/
    │   └── README.md
    └── day-02/
        └── README.md
```

Screenshots are published only after removing unnecessary account identifiers and sensitive information.

## Interview Talking Point

> I built an event-driven AWS security detection pipeline for sensitive IAM policy activity. CloudTrail records write management events, EventBridge filters high-value IAM API calls, and a Python Lambda function converts matched events into structured incidents in DynamoDB. I applied least privilege to both the Lambda execution role and EventBridge invocation permission, then validated the full workflow with a live DeletePolicy event using EventBridge metrics, Lambda metrics, CloudWatch logs, and DynamoDB evidence.

## Next Phase

Day 3 can extend the pipeline with **SNS alerting and notification**, followed by automated response logic, API integration, and Terraform-based infrastructure deployment.
