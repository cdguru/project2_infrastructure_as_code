# Deployed here
#
# CodeDeploy resources

# CodeDeploy Application
resource "aws_codedeploy_app" "lambda_application" {
  name = "${var.name}_lambda_application"
  compute_platform = "Lambda"
}

# CodeDeploy Deployment Group
resource "aws_codedeploy_deployment_group" "lambda_deployment_group" {
  app_name          = aws_codedeploy_app.lambda_application.name
  deployment_group_name = "${var.name}_lambda_deployment_group"

  deployment_config_name = "CodeDeployDefault.LambdaAllAtOnce"

  service_role_arn = aws_iam_role.codedeploy_role.arn
  auto_rollback_configuration {
    enabled = false
  }
  deployment_style {
    deployment_type = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }
}