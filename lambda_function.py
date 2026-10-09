import boto3
import os
import uuid
from datetime import datetime, timezone

# AWS service connections
dynamodb = boto3.resource("dynamodb")
sns = boto3.client("sns")

# Terraform-provided environment variables
sns_topic_arn = os.environ["SNS_TOPIC_ARN"]
table_name = os.environ["DYNAMODB_TABLE"]
table = dynamodb.Table(table_name)


def lambda_handler(event, context):

    # Generate unique incident ID
    incident_id = f"INC-{uuid.uuid4().hex[:8].upper()}"

    # ------------------------------------------------
    # Detect whether this came from EventBridge
    # ------------------------------------------------
    detail = event.get("detail", {})

    if (
        event.get("source") == "aws.iam"
        and event.get("detail-type") == "AWS API Call via CloudTrail"
    ):
        # Real IAM event from CloudTrail/EventBridge
        event_name = detail.get("eventName", "UnknownIAMActivity")

        incident = {
            "incident_id": incident_id,
            "event_type": event_name,
            "severity": "HIGH",
            "status": "OPEN",
            "source": "EventBridge/CloudTrail",
            "description": f"Sensitive IAM activity detected: {event_name}",
            "timestamp": datetime.now(timezone.utc).isoformat()
        }

    else:
        # Manual testing path
        incident = {
            "incident_id": incident_id,
            "event_type": event.get(
                "event_type",
                "TerraformTestIncident"
            ),
            "severity": event.get("severity", "MEDIUM"),
            "status": "OPEN",
            "source": "Terraform-Lambda",
            "description": event.get(
                "description",
                "Security incident processed by Terraform-deployed Lambda"
            ),
            "timestamp": datetime.now(timezone.utc).isoformat()
        }

    # Store incident in Terraform DynamoDB table
    table.put_item(Item=incident)

    # Publish alert through Terraform SNS topic
    alert_message = (
        f"Security Incident Alert\n\n"
        f"Incident ID: {incident['incident_id']}\n"
        f"Event Type: {incident['event_type']}\n"
        f"Severity: {incident['severity']}\n"
        f"Status: {incident['status']}\n"
        f"Source: {incident['source']}\n"
        f"Description: {incident['description']}\n"
        f"Timestamp: {incident['timestamp']}"
    )

    sns.publish(
        TopicArn=sns_topic_arn,
        Subject=f"Security Alert - {incident['severity']}",
        Message=alert_message
    )

    print(
        f"Incident processed: {incident_id} | "
        f"{incident['event_type']} | "
        f"{incident['source']}"
    )

    return {
        "statusCode": 200,
        "incident_id": incident_id,
        "message": "Security incident stored successfully"
    }