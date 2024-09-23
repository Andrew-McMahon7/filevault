resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "DynamoDB-Terraform-${local.environment}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 10
  write_capacity = 10
  hash_key       = "name"
  range_key      = "key"

  attribute {
    name = "name"
    type = "S"
  }

  attribute {
    name = "key"
    type = "S"
  }

  global_secondary_index {
    name               = "nameIndex"
    hash_key           = "name"
    range_key          = "key"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "KEYS_ONLY"
    non_key_attributes = []
  }

  depends_on = [null_resource.enforce_workspace]
}