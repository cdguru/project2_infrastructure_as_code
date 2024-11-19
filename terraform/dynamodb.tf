# Deployed here
#
# DynamoDB resources
# DynamoDB items for this demo

# DynamoDB table
resource "aws_dynamodb_table" "dynamodb_table" {
  name           = "${var.name}_UserProfiles"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "userId"

  attribute {
    name = "userId"
    type = "S"
  }
  attribute {
    name = "username"
    type = "S"
  }

  global_secondary_index {
    name               = "username-index"
    hash_key           = "username"
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "INCLUDE"
    non_key_attributes = ["ALL"]
  }  

  tags = {
    Name        = "${var.name}_UserProfiles"
    Environment = "dev"
  }
}

# DynamoDB item
resource "aws_dynamodb_table_item" "dynamo_item1" {
  table_name = aws_dynamodb_table.dynamodb_table.name
  hash_key   = aws_dynamodb_table.dynamodb_table.hash_key

  item = <<ITEM
{
    "username": {"S": "user1"},
    "userId": {"S": "001"},
    "name": {"S": "John Doe"},
    "email": {"S": "john.doe@example.com"},
    "age": {"N": "30"}
}
ITEM
}

# DynamoDB item
resource "aws_dynamodb_table_item" "dynamo_item2" {
  table_name = aws_dynamodb_table.dynamodb_table.name
  hash_key   = aws_dynamodb_table.dynamodb_table.hash_key

  item = <<ITEM
{
    "username": {"S": "user2"},
    "userId": {"S": "002"},
    "name": {"S": "Jane Smith"},
    "email": {"S": "jane.smith@example.com"},
    "age": {"N": "27"}
}
ITEM
}

# DynamoDB item
resource "aws_dynamodb_table_item" "dynamo_item3" {
  table_name = aws_dynamodb_table.dynamodb_table.name
  hash_key   = aws_dynamodb_table.dynamodb_table.hash_key

  item = <<ITEM
{
    "username": {"S": "user3"},
    "userId": {"S": "003"},
    "name": {"S": "Alex Johnson"},
    "email": {"S": "alex.johnson@example.com"},
    "age": {"N": "35"}
}
ITEM
}