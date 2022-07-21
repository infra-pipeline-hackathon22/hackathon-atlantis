resource "aws_s3_bucket" "b" {
  bucket = "benjamins-buckets"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}
