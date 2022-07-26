
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "Backend"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "User"
  attribute {
    name = "User"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}
