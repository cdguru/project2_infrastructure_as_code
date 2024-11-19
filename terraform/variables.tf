#
# General
variable "name" {
  type = string
  description = "Name of the APP"
}
# Codepipeline
variable "lambda_repository_id" {
  type = string
  description = "The lambda repo id. Format: <org-name>/<repo-name>"
}
variable "repository_branch" {
  type = string
  description = "The branch for dev env"
}
