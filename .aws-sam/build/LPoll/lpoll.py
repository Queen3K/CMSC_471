import json
import os
import boto3

dynamodb = boto3.resource("dynamodb")


def handler(event, context):
    # CORS preflight
    if event.get("httpMethod") == "OPTIONS":
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type",
                "Access-Control-Allow-Methods": "OPTIONS,GET"
            },
            "body": ""
        }

    # GET /api/jobs/{jobId}
    job_id = event.get("pathParameters", {}).get("jobId")

    if not job_id:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"message": "jobId is required"})
        }

    result = dynamodb.Table(os.environ["JOB_TABLE"]).get_item(
        Key={
            "jobId": job_id
        }
    )

    item = result.get("Item", {})

    print(json.dumps(event))

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({
            "jobId": job_id,
            "status": item.get("status", "UNKNOWN"),
            "message": item.get("message", "...")
        })
    }