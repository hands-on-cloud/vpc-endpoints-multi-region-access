# Demo S3 bucket us-east-1

resource "aws_s3_bucket" "s3_us_east_1" {
  bucket = "${local.prefix}-s3-us-east-1"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "s3_us_east_1" {
  bucket                  = aws_s3_bucket.s3_us_east_1.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Demo S3 bucket us-east-2

resource "aws_s3_bucket" "s3_us_east_2" {
  bucket = "${local.prefix}-s3-us-east-2"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = false
  }

  tags = local.common_tags

  provider = aws.us-east-2
}

resource "aws_s3_bucket_public_access_block" "s3_us_east_2" {
  bucket                  = aws_s3_bucket.s3_us_east_2.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  provider = aws.us-east-2
}
