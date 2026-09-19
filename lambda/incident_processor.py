import json
import boto3
import logging

# Configure application logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Connect to the project DynamoDB table
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("BonTech-Security-Incidents")


def lambda_handler(event, context):
    incident = {
        "incident_id": "INC-002",
        "event_type": "UnauthorizedAccess",
        "severity": "HIGH",
        "status": "OPEN",
        "source": "AWS",
        "description": "Unauthorized access attempt detected",
    }

    logger.info(
        "Processing incident: %s | Event: %s | Severity: %s | Status: %s",
        incident["incident_id"],
        incident["event_type"],
        incident["severity"],
        incident["status"],
    )

    table.put_item(Item=incident)

    logger.info(
        "Incident %s successfully stored in DynamoDB",
        incident["incident_id"],
    )

    return {
        "statusCode": 200,
        "body": json.dumps("Incident successfully stored in DynamoDB"),
    }
