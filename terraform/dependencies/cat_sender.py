import json, boto3, urllib.parse, os, requests, base64
from decimal import Decimal

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')

# Get table name from ARN, use it to access DynamoDB table
table_arn = os.environ.get('DYNAMODB_TABLE_ARN')
table_name = table_arn.split('/')[-1]
table = dynamodb.Table(table_name)

def lambda_handler(event, context):

    print("## STARTING THE LAMBDA")
    label_info = {}

    record = event['Records'][0]

    bucket = record['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(record['s3']['object']['key'], encoding='utf-8')
    
    print(f"Processing image: s3://{bucket}/{key}")
    
    # Call Rekognition API
    image_content = s3.get_object(Bucket=bucket, Key=key)['Body'].read()
    payload = json.dumps(base64.b64encode(image_content).decode('utf-8'))

    response = requests.post("https://7ns0ipq1jd.execute-api.us-east-1.amazonaws.com/PROD/label-it", \
        headers={"Content-Type": "application/json", "Accept": "application/json"}, \
        data=payload
    ).json()
    
    print('Received response:')
    print(response)
    
    # Store in DynamoDB
    label_info = {
            'Key': key,
            'Labels': [{
                'Name': label['Name'],
                'Confidence': Decimal(label['Confidence'])
            } for label in response['body']['Labels']]
        }
    table.put_item(Item=label_info)

    return {
        'statusCode': 200,
        'body': label_info
    }