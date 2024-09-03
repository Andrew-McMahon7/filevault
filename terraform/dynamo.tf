resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "DynamoDB-Terraform"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
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
    write_capacity     = 10
    read_capacity      = 10
    projection_type    = "KEYS_ONLY"  # Corrected projection_type
    non_key_attributes = []
  }
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
}