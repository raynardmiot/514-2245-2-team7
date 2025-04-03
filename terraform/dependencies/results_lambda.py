import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
# Get table name from ARN, use it to access DynamoDB table
table_arn = os.environ.get('DYNAMODB_TABLE_ARN')
table_name = table_arn.split('/')[-1]
table = dynamodb.Table(table_name)


def lambda_handler(event, context):
    file_name = event["queryStringParameters"]['file_name']
    response = table.get_item(
        Key={
            'Key': file_name
        }
    )

    print(response)
    
    body = {
        'Key': response['Item']['Key'],
        'Labels': [{
            'Name': label['Name'],
            'Confidence': float(label['Confidence'])}
            for label in response['Item']['Labels']
        ]
    }

    return {
        "isBase64Encoded": False,
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "OPTIONS,POST,GET,PUT",
            "Access-Control-Allow-Headers": "Content-Type"
        },
        "body": json.dumps(body)
    }
