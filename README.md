# BonTech AWS Serverless Security Incident Automation

A hands-on AWS cloud security engineering project building a serverless security incident automation platform with **CloudTrail, EventBridge, AWS Lambda, Python/Boto3, DynamoDB, Amazon SNS, IAM least privilege, CloudWatch, and controlled automated IAM remediation**.

> **Project status:** Day 5 completed — event-driven IAM detection, controlled IAM remediation, and API-driven incident ingestion validated end-to-end.

## Project Goal

Build a security automation workflow that detects sensitive AWS activity, processes it with serverless Python, persists structured incidents, and automatically notifies a security analyst while providing operational evidence for investigation and troubleshooting.

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
        +------> Controlled IAM Remediation (Day 4)
        |
        +------> DynamoDB (incident record)
        |
        +------> CloudWatch Logs
        |
        +------> Amazon SNS
                    |
                    v
             Security Analyst Email

Future phases:
External API Client / PowerShell
        |
        v
Amazon API Gateway (POST /incidents)
        |
        +------> AWS Lambda (same incident processor)
                    |
                    +------> DynamoDB / CloudWatch / SNS

Future phase:
        +------> Terraform
```

## Day 1 — Serverless Incident Processing Foundation

- Created `BonTech-Security-Incidents` DynamoDB table.
- Created `BonTech-Incident-Processor` Lambda using Python/Boto3.
- Scoped the Lambda execution role to `dynamodb:PutItem` on the project table.
- Validated Lambda-to-DynamoDB persistence.
- Added CloudWatch application logging.

See [Day 1 documentation](docs/day-01.md) and [Day 1 evidence](evidence/day-01/).

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

See [Day 2 documentation](docs/day-02.md) and [Day 2 evidence](evidence/day-02/).

## Day 3 — Automated Security Alerting with Amazon SNS

Day 3 extended the incident automation pipeline with Amazon SNS so processed security incidents can automatically generate analyst notifications.

### Implemented

- Created the `BonTech-Security-Alerts` SNS topic.
- Configured and confirmed an email subscription.
- Added a dedicated least-privilege `sns:Publish` permission to the Lambda execution role.
- Integrated Amazon SNS with the Python Lambda function using Boto3.
- Generated structured security alert messages containing incident ID, event type, severity, status, source, and description.
- Published alerts automatically after incident processing.
- Validated successful SNS publishing through CloudWatch logs.
- Verified security incident persistence in DynamoDB.
- Verified delivery of the automated security alert by email.

### Day 3 Workflow

**Detect → Process → Record → Log → Alert**

The completed workflow demonstrates how a cloud security event can move from detection to analyst notification without requiring manual intervention.

See [Day 3 documentation](docs/day-03.md) and [Day 3 evidence](evidence/day-03/).

## Day 4 — Controlled Automated IAM Remediation

Day 4 extended the pipeline from detection and alerting into a tightly scoped automated-response workflow.

- Created dedicated test user `BonTech-Remediation-Test-User`.
- Added least-privilege `iam:DetachUserPolicy` authorization scoped to that test user.
- Added a Boto3 IAM client and parsed CloudTrail `requestParameters`.
- Added a safety gate requiring the exact `AttachUserPolicy` event, test username, and `AmazonS3ReadOnlyAccess` policy ARN.
- Automatically detached the test policy when all conditions matched.
- Changed the incident state to `REMEDIATED` after successful response.
- Verified remediation in CloudWatch, DynamoDB, the IAM user permissions page, and the SNS email alert.

### Day 4 Workflow

**Detect → Validate → Remediate → Record → Log → Alert**

See [Day 4 documentation](docs/day-04.md) and [Day 4 evidence](evidence/day-04/).

## Day 5 — API Gateway Security Incident Ingestion

Day 5 added an external REST API path so incidents can enter the same serverless security workflow programmatically.

- Created REST API `BonTech-Security-Incident-API`.
- Created `POST /incidents` with Lambda proxy integration.
- Deployed the API to the `dev` stage.
- Updated Lambda to parse API Gateway JSON requests while preserving EventBridge/CloudTrail processing.
- Added HTTP `201` success responses and `400` handling for invalid JSON.
- Validated the API from the API Gateway console and an external PowerShell `Invoke-RestMethod` request.
- Verified the same API-created incident across PowerShell, DynamoDB, CloudWatch, SNS, and email.

### Day 5 Workflow

**Submit → API Gateway → Process → Record → Log → Alert**

See [Day 5 documentation](docs/day-05.md) and [Day 5 evidence](evidence/day-05/).

## Detection Pattern

The EventBridge event pattern is also stored as a standalone configuration file at [`eventbridge/sensitive-iam-activity-pattern.json`](eventbridge/sensitive-iam-activity-pattern.json).

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

The Lambda execution role follows least privilege. It permits the DynamoDB write required for incident persistence and a separately scoped SNS publish permission for the project alert topic. Day 4 adds a tightly scoped IAM remediation permission for the dedicated lab user.

DynamoDB permission:

```json
{
  "Effect": "Allow",
  "Action": "dynamodb:PutItem",
  "Resource": "arn:aws:dynamodb:us-east-1:<ACCOUNT-ID>:table/BonTech-Security-Incidents"
}
```

SNS permission:

```json
{
  "Effect": "Allow",
  "Action": "sns:Publish",
  "Resource": "arn:aws:sns:us-east-1:<ACCOUNT-ID>:BonTech-Security-Alerts"
}
```

IAM remediation permission:

```json
{
  "Effect": "Allow",
  "Action": "iam:DetachUserPolicy",
  "Resource": "arn:aws:iam::<ACCOUNT-ID>:user/BonTech-Remediation-Test-User"
}
```

### Lambda invocation authorization

A separate Lambda resource-based policy allows `events.amazonaws.com` to invoke the function and restricts the permission to the project's EventBridge rule ARN.

This separates **who can invoke the function** from **what the function can do**.

## End-to-End Validation

The project has validated the following security automation chain:

```text
Sensitive IAM activity
      ↓
CloudTrail records the management event
      ↓
EventBridge matches the security event
      ↓
Lambda processes and classifies the incident
      ↓
For the controlled Day 4 test, Lambda validates the exact user/policy and detaches the policy
      ↓
DynamoDB stores the structured incident with REMEDIATED status
      ↓
CloudWatch records execution and application logs
      ↓
Amazon SNS publishes the security notification
      ↓
Security analyst receives the alert by email
```

## Repository Structure

```text
.
├── README.md
├── lambda/
│   └── incident_processor.py
├── eventbridge/
│   └── sensitive-iam-activity-pattern.json
├── docs/
│   ├── day-01.md
│   ├── day-02.md
│   ├── day-03.md
│   ├── day-04.md
│   └── day-05.md
└── evidence/
    ├── day-01/
    │   ├── README.md
    │   └── 6 sanitized AWS evidence screenshots
    ├── day-02/
    │   ├── README.md
    │   └── 6 sanitized AWS evidence screenshots
    ├── day-03/
    │   ├── README.md
    │   └── AWS Security Automation Evidence Collage.png
    ├── day-04/
    │   └── README.md + sanitized validation screenshots
    └── day-05/
        └── README.md + 6 sanitized validation screenshots
```

Screenshots are published only after removing unnecessary account identifiers and sensitive information.

## Interview Talking Point

> I built an event-driven AWS security incident automation pipeline for sensitive IAM activity. CloudTrail records management events, EventBridge filters high-value IAM API calls, and a Python/Boto3 Lambda function converts matched events into structured incidents in DynamoDB. I applied least privilege to both the Lambda execution role and EventBridge invocation permission. I then extended the workflow with Amazon SNS so processed incidents automatically generate security notifications for the analyst. In Day 4, I added a tightly scoped automated IAM response that validates an exact test user and policy before calling DetachUserPolicy, then records the incident as REMEDIATED. I validated the workflow using IAM before/after state, CloudWatch logs, DynamoDB records, and successful email alert delivery.

## Next Phase

The next iteration can add **Terraform-based infrastructure deployment**, followed by stronger production controls such as API authorization, request validation, throttling, and environment-specific configuration.
