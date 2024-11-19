# Deployed here
#
# S3 resources

# Create a zip of the content of specs dir and leave it in upload directory
data "archive_file" "specs" {
  type        = "zip"
  source_dir  = "${path.module}/../specs"
  output_path = "${path.module}/upload/specs.zip"
}

# Create a bucket for CodePipeline
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.name}-codepipeline-bucket"

  tags = {
    Name = "${var.name}-codepipeline-bucket"
  }

}

# Config the ownership of the bucket objects.
resource "aws_s3_bucket_ownership_controls" "ownership_controls_config_bucket" {
  bucket = aws_s3_bucket.codepipeline_bucket.bucket

  rule {
    object_ownership = "ObjectWriter"
  }
}

# Set acl
resource "aws_s3_bucket_acl" "codepipeline_bucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"

  depends_on = [ aws_s3_bucket_ownership_controls.ownership_controls_config_bucket ]
}

# Enable versioning
resource "aws_s3_bucket_versioning" "codepipeline_bucket_versioning" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  versioning_configuration {
    status = "Enabled"
  }

  depends_on = [ aws_s3_bucket_ownership_controls.ownership_controls_config_bucket ]
}

# Upload specs.zip into CodePipeline bucket
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  key    = "source/specs.zip"
  source = "${path.module}/upload/specs.zip"

  depends_on = [ 
    aws_s3_bucket.codepipeline_bucket,
    data.archive_file.specs,
  ]

}