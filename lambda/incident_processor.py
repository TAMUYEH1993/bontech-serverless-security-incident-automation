import json
import boto3
import logging
import uuid
from datetime import datetime, timezone

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("BonTech-Security-Incidents")


def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))

    detail = event.get("detail", {})
    event_name = detail.get("eventName", "UnknownEvent")

    incident = {
        "incident_id": f"INC-{uuid.uuid4().hex[:8].upper()}",
        "event_type": event_name,
        "severity": "HIGH",
        "status": "OPEN",
        "source": "EventBridge/CloudTrail",
        "description": f"Sensitive IAM activity detected: {event_name}",
        "timestamp": datetime.now(timezone.utc).isoformat(),
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
