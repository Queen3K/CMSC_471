import json
import os
import boto3
import uuid
from datetime import datetime, timezone

dynamodb = boto3.resource("dynamodb")


def handler(event, context):
    job_id = event["jobId"]
    items = event.get("items", [])

    records_table = dynamodb.Table(os.environ["RECORDS_TABLE"])

    for item in items:
        records_table.put_item(
            Item={
                "id": str(uuid.uuid4()),
                "job_id": job_id,
                "item": str(item),
                "created_at": datetime.now(timezone.utc).isoformat()
            }
        )

    dynamodb.Table(os.environ["JOB_TABLE"]).update_item(
        Key={"jobId": job_id},
        UpdateExpression="SET #s = :v1, #m = :v2",
        ExpressionAttributeNames={
            "#s": "status",
            "#m": "message"
        },
        ExpressionAttributeValues={
            ":v1": "SUCCEEDED",
            ":v2": f"Saved {len(items)} items to table"
        }
    )

    print(json.dumps(event))

    return {
        "jobId": job_id,
        "rowCount": len(items)
    }