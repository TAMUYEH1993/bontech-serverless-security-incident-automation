# BonTech AWS Serverless Security Incident Automation

A hands-on AWS cloud security engineering project that builds a serverless security incident automation platform using **AWS Lambda, Python/Boto3, DynamoDB, IAM least privilege, CloudWatch, EventBridge, SNS, API Gateway, and Terraform**.

> **Project status:** Day 1 completed — serverless incident processing foundation.

## Project Goal

Build an AWS security automation workflow that can receive security events, process them with Python, persist incident records, produce operational logs, and later trigger alerts and automated response actions.

### Target architecture

```text
Security Event
      |
      v
EventBridge
      |
      v
AWS Lambda (Python/Boto3)
      |
      +------> DynamoDB (incident record)
      |
      +------> CloudWatch Logs
      |
      +------> SNS (later)
      |
      +------> Automated Response (later)
```

Day 1 intentionally focuses on the foundation. EventBridge, SNS, API Gateway, automated remediation, and Terraform will be added in later stages.

## Day 1 — Serverless Incident Processing Foundation

### What I built

- Created the `BonTech-Security-Incidents` DynamoDB table for incident records.
- Added a baseline incident, `INC-001`, to validate the data model.
- Created the `BonTech-Incident-Processor` AWS Lambda function using Python.
- Used **Boto3**, the AWS SDK for Python, to communicate with DynamoDB.
- Configured an IAM execution role using the **principle of least privilege**.
- Allowed only `dynamodb:PutItem` against the project incident table rather than broad DynamoDB access.
- Invoked Lambda with a test event and generated `INC-002`.
- Verified the incident was successfully persisted in DynamoDB.
- Added Python application logging and verified execution details in CloudWatch Logs.

## Day 1 Data Flow

```text
Lambda Test Event
      |
      v
BonTech-Incident-Processor
      |
      v
Python
      |
      v
Boto3
      |
      v
DynamoDB PutItem API
      |
      v
IAM Authorization
      |
      v
BonTech-Security-Incidents
      |
      +--> INC-002 stored

Lambda
      |
      +--> CloudWatch Logs
           - incident processing log
           - DynamoDB success log
           - START / END / REPORT
```

## Security Design — Least Privilege

The Lambda execution role was deliberately scoped to the operation required by the function:

```json
{
  "Effect": "Allow",
  "Action": "dynamodb:PutItem",
  "Resource": "arn:aws:dynamodb:us-east-1:<ACCOUNT-ID>:table/BonTech-Security-Incidents"
}
```

The account ID is intentionally redacted in this public documentation.

This prevents the function from receiving unnecessary permissions such as `dynamodb:*`, `DeleteTable`, or unrestricted access to every DynamoDB table.

## Day 1 Verification

The Day 1 test demonstrated that:

1. Lambda successfully executed the Python function.
2. Boto3 issued the DynamoDB request.
3. IAM authorized the permitted `PutItem` operation.
4. DynamoDB stored incident `INC-002`.
5. CloudWatch captured Lambda execution metrics and application logs.
6. The Lambda invocation completed successfully with no execution error.

The application logs included messages equivalent to:

```text
Processing incident: INC-002 | Event: UnauthorizedAccess | Severity: HIGH | Status: OPEN
Incident INC-002 successfully stored in DynamoDB
```

## Incident Schema

| Attribute | Example |
|---|---|
| `incident_id` | `INC-002` |
| `event_type` | `UnauthorizedAccess` |
| `severity` | `HIGH` |
| `status` | `OPEN` |
| `source` | `AWS` |
| `description` | `Unauthorized access attempt detected` |

## AWS Services Used on Day 1

| Service / Technology | Purpose |
|---|---|
| AWS Lambda | Serverless incident-processing compute |
| Python | Application and automation logic |
| Boto3 | AWS SDK used by Python to call AWS services |
| DynamoDB | Persistent security incident storage |
| IAM | Lambda execution identity and least-privilege authorization |
| CloudWatch Logs | Function execution and application logging |

## Repository Structure

```text
.
├── README.md
├── lambda/
│   └── incident_processor.py
├── docs/
│   └── day-01.md
└── evidence/
    └── day-01/
        └── README.md
```

Screenshots will be added only after checking/redacting unnecessary AWS account identifiers and other sensitive information.

## Interview Talking Point

> I built a Python-based AWS Lambda incident processor that uses Boto3 to persist security incidents in DynamoDB. I applied least-privilege IAM by limiting the execution role to the required DynamoDB PutItem operation on the project table. I also implemented application logging in CloudWatch so incident processing and successful database writes can be monitored and troubleshot.

## Next Phase

The next stages will evolve the manually tested foundation into an event-driven security automation platform by introducing EventBridge, SNS alerting, dynamic event processing, API Gateway, automated response logic, and Infrastructure as Code with Terraform.
