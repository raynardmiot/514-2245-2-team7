import json
import boto3
import uuid

print('Loading function')

s3 = boto3.client('s3')
BUCKET_NAME = 'swen-514-7-image-bucket-with-unique-name'

def lambda_handler(event, context):
    image_id = str(uuid.uuid4())  
    key = f"{uuid.uuid4()}.jpg"   

    upload_url = s3.generate_presigned_url(
        'put_object',
        Params={
            'Bucket': BUCKET_NAME, 
            'Key': key, 
            'ContentType': 'image/jpeg'  
        },
        ExpiresIn=3600
    )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "imageId": image_id,
            "url": upload_url  
        })
    }

