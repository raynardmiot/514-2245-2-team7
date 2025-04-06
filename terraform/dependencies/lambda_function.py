import json, boto3, uuid, base64

print('Loading function')

s3 = boto3.client('s3')
BUCKET_NAME = os.environ.get('S3_BUCKET_NAME')

def lambda_handler(event, context):
    print("received event")
    print(event)

    image_id = str(uuid.uuid4())  
    key = f"{uuid.uuid4()}.jpg"   

    # upload image to s3
    s3.put_object(
        Bucket=BUCKET_NAME,
        Key=key,
        Body=base64.b64decode(event['body'])
    )

    return {
        "statusCode": 200,
        "headers": {
             "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET,PUT",
                "Access-Control-Allow-Headers": "Content-Type"
        },
        "body": json.dumps({
            "filename": key,
        })
    }
