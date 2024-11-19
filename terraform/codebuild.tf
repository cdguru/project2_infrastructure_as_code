# Deployed here
#
# CodeBuild Project resources

# CodeBuild project to deploy our lambda
resource "aws_codebuild_project" "build_project" {
  name          = "${var.name}_build_project"
  service_role  = aws_iam_role.codebuild_role.arn
  

  artifacts {
    type = "CODEPIPELINE"
  }
  
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"

    environment_variable {
        name  = "LAMBDA_FUNCTION_NAME"
        value = "${var.name}_lambda"
    }
  }
  
  source {
    type            = "CODEPIPELINE"
  }
}