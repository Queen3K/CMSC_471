import json
import boto3
import os
from botocore.client import Config
from urllib.parse import unquote_plus

s3 = boto3.client(
    "s3",
    region_name="us-east-1",
    config=Config(signature_version="s3v4")
)

BUCKET = os.environ["INBOX_BUCKET_NAME"]


def handler(event, context):
    print(json.dumps(event))

    method = event["httpMethod"]
    headers = {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json"
    }

    if method == "GET":
        response = s3.list_objects_v2(Bucket=BUCKET)
        files = [obj["Key"] for obj in response.get("Contents", [])]

        return {
            "statusCode": 200,
            "headers": headers,
            "body": json.dumps(files)
        }

    if method == "POST":
        body = json.loads(event["body"])
        filename = body["filename"]

        url = s3.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": BUCKET,
                "Key": filename,
                "ContentType": "image/png"
            },
            ExpiresIn=300
        )

        return {
            "statusCode": 200,
            "headers": headers,
            "body": json.dumps({
                "url": url,
                "key": filename
            })
        }

    if method == "DELETE":
        key = event["pathParameters"]["key"]
        key = unquote_plus(key)
        s3.delete_object(Bucket=BUCKET, Key=key)

        return {
            "statusCode": 200,
            "headers": headers,
            "body": json.dumps({
                "deleted": key
            })
        }

    return {
        "statusCode": 405,
        "headers": headers,
        "body": json.dumps({
            "error": "Method not allowed"
        })
    }