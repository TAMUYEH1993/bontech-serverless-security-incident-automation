# Day 5 – API Gateway Security Incident Ingestion

## Objective

Extend the BonTech serverless security automation platform with an external REST API entry point so security incidents can be submitted programmatically and processed by the same Lambda, DynamoDB, CloudWatch, and SNS workflow.

## Implementation

- Created REST API `BonTech-Security-Incident-API` in Amazon API Gateway.
- Created the `/incidents` resource with a `POST` method.
- Integrated the method with `BonTech-Incident-Processor` using Lambda proxy integration.
- Updated the Lambda handler to recognize API Gateway `POST /incidents` events and parse the JSON request body.
- Added safe defaults for incident ID, event type, severity, status, source, description, and UTC timestamp.
- Added a `400` JSON response for malformed request bodies.
- Preserved the existing EventBridge/CloudTrail detection and controlled IAM remediation paths.
- Deployed the API to the `dev` stage.
- Tested through both the API Gateway console and an external PowerShell `Invoke-RestMethod` request.

## Day 5 Workflow

```text
PowerShell / API Client
        ↓
API Gateway REST API
POST /dev/incidents
        ↓
Lambda: BonTech-Incident-Processor
        ↓
Parse and normalize incident JSON
        ↓
DynamoDB: BonTech-Security-Incidents
        ↓
CloudWatch application logs
        ↓
Amazon SNS
        ↓
Security analyst email
```

## Validation

The external PowerShell test returned application data confirming creation of incident `INC-6C7BD6F0` with `OPEN` status and `API-Gateway` source. The same incident ID was then verified in DynamoDB, CloudWatch processing logs, and the SNS email alert.

The Lambda/API response uses HTTP `201` for successful API-created incidents and returns a JSON body containing the generated incident ID, status, and source.

## Security Notes

This lab API currently demonstrates the ingestion and automation path. A production deployment should add authentication/authorization, request validation, throttling/usage controls, WAF protections where appropriate, structured error handling, and environment-specific configuration. Public portfolio source code replaces account-specific ARNs with `<ACCOUNT-ID>` placeholders.

See the sanitized evidence in `evidence/day-05/`.
