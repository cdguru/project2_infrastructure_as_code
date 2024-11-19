# Deployed here
#
# Api-Gateway resources

# API Gateway REST API
resource "aws_api_gateway_rest_api" "user_profile_api" {
  name        = "${var.name}_UserProfileAPI"
  description = "[Project2] API for accessing user profiles"
}

# API Gateway Resource (root path)
resource "aws_api_gateway_resource" "user_profile_resource" {
  rest_api_id = aws_api_gateway_rest_api.user_profile_api.id
  parent_id   = aws_api_gateway_rest_api.user_profile_api.root_resource_id
  path_part   = "user"
}

# API Gateway Method (GET /user/{username})
resource "aws_api_gateway_method" "get_user_method" {
  rest_api_id   = aws_api_gateway_rest_api.user_profile_api.id
  resource_id   = aws_api_gateway_resource.user_profile_resource.id
  http_method   = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.username" = true
  }
}

# Integration with Lambda Function
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.user_profile_api.id
  resource_id             = aws_api_gateway_resource.user_profile_resource.id
  http_method             = aws_api_gateway_method.get_user_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.project2_lambda.invoke_arn
}

# Deploy the API
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.user_profile_api.id
  stage_name  = "v1"
  depends_on  = [aws_api_gateway_integration.lambda_integration]
}

# API Key
resource "aws_api_gateway_api_key" "user_api_key" {
  name      = "UserProfileAPIKey"
  enabled   = true
}

# Usage Plan for API Key
resource "aws_api_gateway_usage_plan" "user_usage_plan" {
  name        = "UserUsagePlan"
  description = "Usage plan for user profile API"
  api_stages {
    api_id = aws_api_gateway_rest_api.user_profile_api.id
    stage  = aws_api_gateway_deployment.api_deployment.stage_name
  }
}

# Attach the API key to the usage plan
resource "aws_api_gateway_usage_plan_key" "user_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.user_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.user_usage_plan.id
}