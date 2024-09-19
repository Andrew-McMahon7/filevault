resource "aws_s3_bucket" "andrewwocbucket" {
  bucket = "andrewwocbucket-${local.environment}"


  tags = {
    Name        = "andrewwocbucket-${local.environment}"
    Environment = local.environment
  }
}

resource "aws_s3_bucket_public_access_block" "andrewwocbucket" {
  bucket = aws_s3_bucket.andrewwocbucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}