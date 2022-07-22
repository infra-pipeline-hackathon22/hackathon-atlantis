resource "aws_s3_bucket" "test_bucket" {
  bucket_prefix = "atlantis-test-"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "transition-objects-to-glacier"
    enabled = true
    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }
}
