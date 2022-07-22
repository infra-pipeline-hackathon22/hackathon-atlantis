
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "Backend"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "User"
  attribute {
    name = "User"
    type = "B"
  }
}
