# Day 4 Evidence – Controlled Automated IAM Remediation

This folder contains sanitized evidence for the Day 4 controlled-remediation workflow.

## Evidence

1. `01-before-remediation-policy-attached.png` — dedicated test user before remediation, with `AmazonS3ReadOnlyAccess` attached.
2. `02-after-remediation-policy-removed.png` — same user after the automation removed the policy.
3. `03-cloudwatch-remediation-success.png` — Lambda logs confirming automated remediation, `REMEDIATED` processing, DynamoDB persistence, and SNS publishing.
4. `04-dynamodb-remediated-incident.png` — persisted incident with status `REMEDIATED`.
5. `05-sns-remediated-alert.png` — analyst notification confirming the automated response.

## Evidence Story

**Before state → Automated response → Execution proof → Persistence → Notification**

Account identifiers and unnecessary sensitive details are redacted before publication.
