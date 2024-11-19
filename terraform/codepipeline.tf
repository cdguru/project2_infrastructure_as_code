# Deployed here
#
# CodePipeline resources
# CodeStart connection resource

# CodePipeline !
resource "aws_codepipeline" "codepipeline" {
  name            = "${var.name}-lambda-pipeline"
  role_arn        = aws_iam_role.codepipeline_role.arn
  pipeline_type   = "V2"
  execution_mode  = "QUEUED"

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.codestar.arn
        FullRepositoryId = var.lambda_repository_id
        BranchName       = var.repository_branch
        DetectChanges    = true
      }

      run_order = "1"
    }
    action {
      name             = "CiCd_Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["cicd_source_output"]

      configuration = {
        S3Bucket    = aws_s3_bucket.codepipeline_bucket.bucket
        S3ObjectKey = "source/specs.zip"
        PollForSourceChanges = false
      }
      
      run_order = "2"
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Package_and_Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output","cicd_source_output"]
      output_artifacts = ["build_output"]
      configuration = {
        ProjectName = aws_codebuild_project.build_project.name
        PrimarySource = "cicd_source_output"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Shift_Traffic"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      version         = "1"
      input_artifacts = ["build_output"]
      configuration = {
        ApplicationName = aws_codedeploy_app.lambda_application.name
        DeploymentGroupName = aws_codedeploy_deployment_group.lambda_deployment_group.deployment_group_name
      }
    }  
  }

  tags = {
    Name = "${var.name}_codepipeline"
  }
}

# CodeStar connection resource to connect to GitHub
resource "aws_codestarconnections_connection" "codestar" {
  name          = "${var.name}_codestar_connection"
  provider_type = "GitHub"
}