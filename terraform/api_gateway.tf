data "archive_file" "upload_lambda_output" {
    type        = "zip"
    source_file = "${path.module}/dependencies/lambda_function.py"
    output_path = "${path.module}/out/lambda_function.zip"
}

resource "aws_lambda_function" "upload_lambda" {
  function_name = "generate_url"
  role          = aws_iam_role.lambda_role.arn
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  filename      = data.archive_file.upload_lambda_output.output_path
  source_code_hash = data.archive_file.upload_lambda_output.output_base64sha256

  environment {
    variables = {
      S3_BUCKET_NAME = var.s3_bucket_name
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_s3_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

data "aws_iam_policy_document" "allow_access_from_other_services" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.lambda_role.arn]
    }
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:PutObjectAcl",
      "s3:GetObjectAcl"
    ]
    resources = ["arn:aws:s3:::${aws_s3_bucket.s3.id}/*"]
  }
}

resource "aws_iam_policy" "lambdas3_policy" {
  name        = "lambdas3_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "VisualEditor0",
      Effect = "Allow",
      Action = [
        "s3:PutObject",
        "s3:GetObjectAcl",
        "s3:GetObject",
        "s3:PutObjectAcl"
      ],
      Resource = "arn:aws:s3:::${aws_s3_bucket.s3.id}/*"
    }]
  })
}

resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.s3.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  policy_arn = aws_iam_policy.lambdas3_policy.arn
  role       = aws_iam_role.lambda_role.name
}


resource "aws_api_gateway_rest_api" "cassidyApi" {
  name        = "Cassidy API"
  description = "API for "
}

resource "aws_api_gateway_resource" "uploadImage" {
  rest_api_id = aws_api_gateway_rest_api.cassidyApi.id
  parent_id   = aws_api_gateway_rest_api.cassidyApi.root_resource_id
  path_part   = "uploadImage"
}

resource "aws_api_gateway_method" "UploadImageToS3" {
  rest_api_id   = aws_api_gateway_rest_api.cassidyApi.id
  resource_id   = aws_api_gateway_resource.uploadImage.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "options_method" {
    rest_api_id   = "${aws_api_gateway_rest_api.cassidyApi.id}"
    resource_id   = "${aws_api_gateway_resource.uploadImage.id}"
    http_method   = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_method_response" "options_200" {
    rest_api_id   = "${aws_api_gateway_rest_api.cassidyApi.id}"
    resource_id   = "${aws_api_gateway_resource.uploadImage.id}"
    http_method   = "${aws_api_gateway_method.options_method.http_method}"
    status_code   = 200
    # response_models = {
    #   "application/json" = "Empty"
    # }
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
    rest_api_id   = "${aws_api_gateway_rest_api.cassidyApi.id}"
    resource_id   = "${aws_api_gateway_resource.uploadImage.id}"
    http_method   = "${aws_api_gateway_method.options_method.http_method}"
    status_code   = "${aws_api_gateway_method_response.options_200.status_code}"
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
    depends_on = ["aws_api_gateway_method_response.options_200"]
}

resource "aws_api_gateway_integration" "options_integration" {
    rest_api_id   = "${aws_api_gateway_rest_api.cassidyApi.id}"
    resource_id   = "${aws_api_gateway_resource.uploadImage.id}"
    http_method   = "${aws_api_gateway_method.options_method.http_method}"
    type          = "MOCK"
    request_templates = {
      "application/json" = jsonencode({
          statusCode = 200
        })
  }
    depends_on = ["aws_api_gateway_method.options_method"]
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.cassidyApi.id
  resource_id             = aws_api_gateway_resource.uploadImage.id
  http_method             = aws_api_gateway_method.UploadImageToS3.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.upload_lambda.invoke_arn
  depends_on    = ["aws_api_gateway_method.UploadImageToS3", "aws_lambda_function.upload_lambda"]
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  
  source_arn =  "${aws_api_gateway_rest_api.cassidyApi.execution_arn}/*"
}




#Get Results Terraform code

#IAM role

resource "aws_iam_role" "getResults_role" {
  name = "get_results_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

#Iam policy

resource "aws_iam_policy" "results_policy" {
  name        = "results_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid    = "VisualEditor0",
      Effect = "Allow",
      Action = [
        	"dynamodb:GetItem",
				  "dynamodb:Scan"
      ],
      "Resource": "arn:aws:dynamodb:*:${var.account_id}:table/*"
    }]
  })
}

data "archive_file" "results_lambda_output" {
    type        = "zip"
    source_file = "${path.module}/dependencies/results_lambda.py"
    output_path = "${path.module}/out/results_lambda.zip"
}

#Lambda
resource "aws_lambda_function" "getResults" {
  function_name = "get_recog_results"
  role          = aws_iam_role.getResults_role.arn
  runtime       = "python3.9"
  handler       = "results_lambda.lambda_handler"
  filename      = data.archive_file.results_lambda_output.output_path
  source_code_hash = data.archive_file.results_lambda_output.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_ARN = aws_dynamodb_table.labels_table.arn
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.getResults_role.name
}

locals {
  static_policies = toset([
    "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess",
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess",
  ])
}

resource "aws_iam_role_policy_attachment" "lambda_dynamo_attach" {
  for_each   = local.static_policies
  policy_arn = each.value
  role       = aws_iam_role.getResults_role.name
}

resource "aws_iam_role_policy_attachment" "dynamic_policy" {
  policy_arn = aws_iam_policy.results_policy.arn
  role       = aws_iam_role.getResults_role.name
}

#API Endpoint
resource "aws_api_gateway_resource" "results" {
  rest_api_id = aws_api_gateway_rest_api.cassidyApi.id
  parent_id   = aws_api_gateway_rest_api.cassidyApi.root_resource_id
  path_part   = "getResults"
}

resource "aws_api_gateway_method" "GetResults" {
  rest_api_id   = aws_api_gateway_rest_api.cassidyApi.id
  resource_id   = aws_api_gateway_resource.results.id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = { "method.request.querystring.file_name" = true }
}

resource "aws_api_gateway_integration" "lambda_integration2" {
  rest_api_id             = aws_api_gateway_rest_api.cassidyApi.id
  resource_id             = aws_api_gateway_resource.results.id
  http_method             = aws_api_gateway_method.GetResults.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.getResults.invoke_arn
}


resource "aws_lambda_permission" "apigw_lambda_get_results" {
  statement_id  = "GetResultsPermissions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getResults.function_name
  principal     = "apigateway.amazonaws.com"
  
  source_arn = "${aws_api_gateway_rest_api.cassidyApi.execution_arn}/*"
}

# api deployment

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.cassidyApi.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.cassidyApi))
  }

  depends_on = [
    aws_api_gateway_method.UploadImageToS3,
    aws_api_gateway_method.GetResults,
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration.lambda_integration2,
    aws_lambda_permission.apigw_lambda,
    aws_lambda_permission.apigw_lambda_get_results
  ]
}


resource "aws_api_gateway_stage" "prod" {
  stage_name    = "testing"
  rest_api_id   = aws_api_gateway_rest_api.cassidyApi.id
  deployment_id = aws_api_gateway_deployment.api_deployment.id
}
