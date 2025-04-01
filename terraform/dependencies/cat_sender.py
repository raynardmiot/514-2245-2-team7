import json
import boto3
from decimal import Decimal
import urllib.parse
import os

s3 = boto3.client('s3')
rekognition = boto3.client('rekognition')
dynamodb = boto3.resource('dynamodb')

# Get table name from ARN, use it to access DynamoDB table
table_arn = os.environ.get('DYNAMODB_TABLE_ARN')
table_name = table_arn.split('/')[-1]
table = dynamodb.Table(table_name)

rekog_arn = os.environ.get('REKOG_PROJECT_ARN')

def lambda_handler(event, context):

    print("## STARTING THE LAMBDA")
    label_info = {}

    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(record['s3']['object']['key'], encoding='utf-8')
        
        print(f"Processing image: s3://{bucket}/{key}")
        
        # Call Rekognition
        response = rekognition.detect_custom_labels(
            Image={
                'S3Object': {
                    'Bucket': bucket,
                    'Name': key
                }
            },
            MinConfidence=80,
            ProjectVersionArn=rekog_arn
        )
        
        print("Labels detected:")
        for label in response['CustomLabels']:
            print(f"- {label['Name']} ({label['Confidence']:.2f}%)")
        
        # Store in DynamoDB
        label_info = {
                'Key': key,
                'Labels': [{
                    'Name': label['Name'],
                    'Confidence': Decimal(str(label['Confidence']))
                } for label in response['CustomLabels']]
            }
        table.put_item(Item=label_info)

    return {
        'statusCode': 200,
        'body': label_info
    }