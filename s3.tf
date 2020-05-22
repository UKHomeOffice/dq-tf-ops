resource "aws_vpc_endpoint" "log_archive" {
  vpc_id          = aws_vpc.opsvpc.id
  route_table_ids = [aws_route_table.ops_route_table.id]
  service_name    = "com.amazonaws.eu-west-2.s3"
}

resource "aws_s3_bucket" "ops_config_bucket" {
  bucket = var.ops_config_bucket
  acl    = var.ops_config_acl
  region = var.region

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

  logging {
    target_bucket = var.log_archive_s3_bucket
    target_prefix = "ops_config_bucket/"
  }

  tags = {
    Name = "ops_config_bucket-${local.naming_suffix}"
  }
}

resource "aws_s3_bucket_policy" "ops_config_bucket" {
  bucket = var.ops_config_bucket

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "HTTP",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "*",
      "Resource": "arn:aws:s3:::${var.ops_config_bucket}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY

}

resource "aws_s3_bucket" "athena_maintenance_bucket" {
  bucket = var.athena_maintenance_bucket
  acl    = var.athena_maintenance_acl
  region = var.region

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

  logging {
    target_bucket = var.log_archive_s3_bucket
    target_prefix = "athena_maintenance_bucket/"
  }

  tags = {
    Name = "athena_maintenance_bucket_${local.naming_suffix}"
  }
}

resource "aws_s3_bucket_policy" "athena_maintenance_bucket" {
  bucket = var.athena_maintenance_bucket

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "HTTP",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "*",
      "Resource": "arn:aws:s3:::${var.athena_maintenance_bucket}/*",
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY

}

