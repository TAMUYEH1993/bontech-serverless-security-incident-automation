# Day 5 Evidence – API Gateway Incident Ingestion

These screenshots document the validated Day 5 workflow. Images were cropped/sanitized before publication to remove unnecessary AWS account identifiers, raw execution metadata, and other environment-specific details.

1. `01-api-gateway-dev-stage.jpg` — deployed `dev` stage and invoke endpoint.
2. `02-api-gateway-post-test-response.jpg` — API Gateway `POST /incidents` test returned HTTP `201` and a created incident response.
3. `03-powershell-api-request-response.jpg` — external PowerShell request successfully created incident `INC-6C7BD6F0`.
4. `04-dynamodb-api-incident-record.jpg` — DynamoDB contains the API-created incident among the project records.
5. `05-sns-api-incident-email.jpg` — SNS delivered the alert for `INC-6C7BD6F0` with source `API-Gateway`.
6. `06-cloudwatch-api-incident-processing.jpg` — CloudWatch application logs show processing, DynamoDB persistence, and SNS publishing for the API-created incident.

## Evidence Story

**Deploy API → Submit Incident → Process in Lambda → Persist in DynamoDB → Log in CloudWatch → Alert through SNS**
