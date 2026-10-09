# Day 4 – Controlled Automated IAM Remediation

## Objective

Extend the serverless security incident pipeline from detection and alerting into a controlled automated response workflow.

## Scenario

A dedicated lab IAM user, `BonTech-Remediation-Test-User`, is used to simulate an unauthorized managed-policy attachment. When `AmazonS3ReadOnlyAccess` is attached to that exact test user, CloudTrail records the `AttachUserPolicy` API call and EventBridge forwards the matching event to the incident-processing Lambda function.

The Lambda function validates the event, user, and policy before taking any remediation action.

## Implementation

- Created the dedicated remediation test IAM user with console access disabled.
- Attached `AmazonS3ReadOnlyAccess` only to generate the controlled test condition.
- Added a least-privilege Lambda IAM permission allowing `iam:DetachUserPolicy` only for the dedicated test user.
- Added a Boto3 IAM client to the existing Lambda function.
- Extracted `userName` and `policyArn` from CloudTrail `requestParameters`.
- Added a three-part safety condition requiring the expected event name, username, and policy ARN.
- Used `iam.detach_user_policy()` to remove the test policy automatically.
- Updated the incident status from `OPEN` to `REMEDIATED` after successful response.
- Preserved DynamoDB persistence, CloudWatch logging, and SNS notification from previous days.

## Controlled Safety Gate

The remediation executes only when all three conditions match:

1. Event name is `AttachUserPolicy`.
2. User is `BonTech-Remediation-Test-User`.
3. Policy is `arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess`.

This prevents the lab function from broadly detaching IAM policies from arbitrary users.

## Validated Workflow

```text
Attach AmazonS3ReadOnlyAccess to dedicated test user
        ↓
CloudTrail records AttachUserPolicy
        ↓
EventBridge matches the IAM event
        ↓
Lambda extracts userName and policyArn
        ↓
Safety gate validates exact test scenario
        ↓
Boto3 calls DetachUserPolicy
        ↓
Policy is automatically removed
        ↓
Incident status becomes REMEDIATED
        ↓
DynamoDB stores the remediated incident
        ↓
CloudWatch records remediation success
        ↓
SNS sends the REMEDIATED security alert
```

## Validation Results

The live test confirmed:

- The test policy was present before the trigger.
- The policy disappeared automatically after the new `AttachUserPolicy` event.
- CloudWatch logged `Automated remediation successful`.
- CloudWatch recorded the incident with status `REMEDIATED`.
- DynamoDB stored the remediated incident.
- SNS delivered an alert showing `Status: REMEDIATED` and the automated-detachment description.

## Security Note

This is intentionally a tightly scoped lab remediation. Production automated response should include stronger safeguards such as approved resource lists, exception handling, rollback strategy, change controls, and environment-specific authorization boundaries.

See the sanitized evidence in `evidence/day-04/`.
