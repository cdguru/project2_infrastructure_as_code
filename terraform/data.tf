# Data pulled here
#
# Current Region
# Current AWS identity information

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}