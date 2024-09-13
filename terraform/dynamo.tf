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

resource "aws_dynamodb_table_item" "item" {
  table_name = aws_dynamodb_table.basic-dynamodb-table.name
  hash_key   = aws_dynamodb_table.basic-dynamodb-table.hash_key
  range_key  = aws_dynamodb_table.basic-dynamodb-table.range_key
  item = <<ITEM
  {
    "name": {"S": "NetflixTitles"},
    "key": {"S": "fc120b543a793c78ffad7d0ebd167462"}
  }
  ITEM

  depends_on = [aws_dynamodb_table.basic-dynamodb-table]
}

resource "aws_dynamodb_table_item" "item2" {
  table_name = aws_dynamodb_table.basic-dynamodb-table.name
  hash_key   = aws_dynamodb_table.basic-dynamodb-table.hash_key
  range_key  = aws_dynamodb_table.basic-dynamodb-table.range_key
  item = <<ITEM
  {
    "name": {"S": "NetflixAgain"},
    "key": {"S": "baa1e28f2731605a79848018ebf92219"}
  }
  ITEM

  depends_on = [aws_dynamodb_table.basic-dynamodb-table]
}