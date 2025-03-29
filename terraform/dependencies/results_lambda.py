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
    
    return {
        "isBase64Encoded": False,  
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*" 
        },
       "body": json.dumps(response['Item'])
    }
