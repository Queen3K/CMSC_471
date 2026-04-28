import json
import os
import boto3
import uuid
from datetime import datetime, timezone

dynamodb = boto3.resource("dynamodb")
sfn = boto3.client("stepfunctions")


def handler(event, context):
    # CORS preflight
    if event.get("httpMethod") == "OPTIONS":
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
            },
            "body": ""
        }

    body = json.loads(event.get("body") or "{}")
    filename = body.get("filename")

    if not filename:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"message": "filename is required"})
        }

    job_id = str(uuid.uuid4())

    dynamodb.Table(os.environ["JOB_TABLE"]).put_item(
        Item={
            "jobId": job_id,
            "status": "RUNNING",
            "message": "Job received, starting...",
            "createdAt": datetime.now(timezone.utc).isoformat()
        }
    )

    sfn.start_execution(
        stateMachineArn=os.environ["STATE_MACHINE_ARN"],
        name=job_id,
        input=json.dumps({
            "jobId": job_id,
            "filename": filename
        })
    )

    print(json.dumps(event))

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({"jobId": job_id})
    }