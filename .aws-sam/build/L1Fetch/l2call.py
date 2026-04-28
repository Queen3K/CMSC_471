import json
import os
import boto3

textract = boto3.client("textract")
dynamodb = boto3.resource("dynamodb")


def handler(event, context):
    job_id = event["jobId"]
    filename = event["filename"]
    bucket = event["bucket"]

    response = textract.detect_document_text(
        Document={
            "S3Object": {
                "Bucket": bucket,
                "Name": filename
            }
        }
    )

    items = [
        block["Text"]
        for block in response.get("Blocks", [])
        if block.get("BlockType") == "LINE" and "Text" in block
    ]

    dynamodb.Table(os.environ["JOB_TABLE"]).update_item(
        Key={"jobId": job_id},
        UpdateExpression="SET #s = :s, #m = :m",
        ExpressionAttributeNames={
            "#s": "status",
            "#m": "message"
        },
        ExpressionAttributeValues={
            ":s": "PROCESSING",
            ":m": f"Textract found {len(items)} items"
        }
    )

    print(json.dumps(event))

    return {
        "jobId": job_id,
        "filename": filename,
        "bucket": bucket,
        "items": items
    }