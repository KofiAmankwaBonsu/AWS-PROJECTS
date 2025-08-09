resource "aws_dynamodb_table" "trucks" {
  name         = "${var.project_name}-trucks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  # Primary key
  attribute {
    name = "id"
    type = "S"
  }

  # GSI for querying by status
  attribute {
    name = "status"
    type = "S"
  }

  # GSI for querying by driver
  attribute {
    name = "driver"
    type = "S"
  }

  # Global Secondary Indexes
  global_secondary_index {
    name            = "StatusIndex"
    hash_key        = "status"
    projection_type = "ALL"
    read_capacity   = 0
    write_capacity  = 0
  }

  global_secondary_index {
    name            = "DriverIndex"
    hash_key        = "driver"
    projection_type = "ALL"
    read_capacity   = 0
    write_capacity  = 0
  }

  # Enable server-side encryption
  server_side_encryption {
    enabled = true
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
