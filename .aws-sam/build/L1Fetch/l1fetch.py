import json
import os
import boto3

s3 = boto3.client('s3')

def handler(event, context):
    job_id = event["jobId"]
    filename = event["filename"]
    bucket = os.environ["BUCKET"]

    s3.get_object(Bucket=bucket, Key=filename)

    print(json.dumps(event))

    return {
        "jobId": job_id,
        "filename": filename,
        "bucket": bucket
    }