# Deployed here
#
# Lambda resources
# CloudWatch resources

# Create a zip of the dummy lambda code
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/dummy_lambda/lambda_function.py"
  output_path = "${path.module}/upload/lambda_function.zip"
}

# Lambda resource
resource "aws_lambda_function" "project2_lambda" {
  function_name = "${var.name}_lambda"
  publish = true

  runtime = "python3.12"

  filename      = "${path.module}/upload/lambda_function.zip"
  handler       = "lambda_function.lambda_handler"

  logging_config {
    log_format = "Text"
    log_group = "/aws/lambda/${var.name}_lambda"
  }

  role = aws_iam_role.lambda_exec.arn
}

# Lambda $LATEST alias resource
resource "aws_lambda_alias" "lambda_alias" {
  name             = "${var.name}_lambda"
  function_name    = aws_lambda_function.project2_lambda.arn
  function_version = "$LATEST"

  depends_on = [ aws_lambda_function.project2_lambda ]
}

# Cloudwatch resource for our lambda
resource "aws_cloudwatch_log_group" "project2_lambda_logs" {
  name = "/aws/lambda/${aws_lambda_function.project2_lambda.function_name}"

  retention_in_days = 1
}

# Lambda permission to let Api-Gateway call the function.
resource "aws_lambda_permission" "apigateway_invoke_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.project2_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.user_profile_api.id}/*/GET/user"
}
