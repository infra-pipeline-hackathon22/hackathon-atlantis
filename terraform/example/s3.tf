terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  backend "s3" {
    dynamodb_table = "terraform-lock"
    bucket         = "atlantis-hackathon-terraform-state"
    region         = "us-west-2"
    key            = "terraform/example"
  }
  required_version = "~> 1.0"
}

variable "role_arn_override" {
  type = string
  default = ""
  description = "The role to assume.  Leave blank to assume no role and use default aws credentials"
}

provider "aws" {
  region = "us-west-2"
  # assume_role {
  #   role_arn = var.role_arn_override
  #   session_name = "my_session"
  # }
}


data "aws_partition" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}

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

# resource "aws_s3_bucket_public_access_block" "associations_bucket_block_public" {
#   bucket                  = aws_s3_bucket.associations_bucket.id
#   block_public_acls       = true
#   block_public_policy     = true
#   restrict_public_buckets = true
#   ignore_public_acls      = true
# }

# # tfsec:ignore:aws-sqs-enable-queue-encryption
# resource "aws_sqs_queue" "associations_to_s3_dlq" {
#   name                    = local.dlq_name
#   sqs_managed_sse_enabled = true
# }

# resource "aws_cloudwatch_metric_alarm" "associations_to_s3_dlq_alarm" {
#   alarm_name          = "associations-to-s3-export-failed-HIGH"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = "NumberOfMessagesSent"
#   namespace           = "AWS/SQS"
#   period              = "120"
#   statistic           = "Sum"
#   threshold           = "1"
#   alarm_description   = "This alarm is triggered when there is more than 1 message in the queue indicating a failed association export to S3"
#   dimensions = {
#     "QueueName" = local.dlq_name
#   }
# }

# data "aws_iam_policy_document" "associations_export_lambda_policy" {
#   statement {
#     actions = [
#       "dynamodb:DescribeStream",
#       "dynamodb:GetRecords",
#       "dynamodb:GetShardIterator",
#       "dynamodb:ListStreams"
#     ]
#     resources = [
#       var.associations_ddb_stream_arn
#     ]
#   }

#   statement {
#     actions = [
#       "execute-api:Invoke"
#     ]
#     resources = [
#       "arn:${local.partition}:execute-api:${local.region}:${local.account_id}:${var.user_association_api_id}/*/*/*"
#     ]
#   }

#   statement {
#     actions = [
#       "s3:PutObject"
#     ]
#     resources = [
#       "${aws_s3_bucket.associations_bucket.arn}",
#       "${aws_s3_bucket.associations_bucket.arn}/*"
#     ]
#   }

#   statement {
#     actions = [
#       "sqs:SendMessage"
#     ]
#     resources = [
#       "${aws_sqs_queue.associations_to_s3_dlq.arn}"
#     ]
#   }
# }

# module "lambda_function" {
#   source  = "terraform-aws-modules/lambda/aws"
#   version = "2.16.0"

#   function_name = "associations-export-to-s3-${var.environment_name}"
#   handler       = "app.handler"
#   runtime       = "python3.9"

#   environment_variables = {
#     EXPORT_BUCKET_NAME            = "${aws_s3_bucket.associations_bucket.id}",
#     DLQ_URL                       = "${aws_sqs_queue.associations_to_s3_dlq.url}",
#     USER_ASSOCIATION_API_ID       = var.user_association_api_id
#     USER_ASSOCIATION_API_ENDPOINT = var.user_association_api_endpoint
#   }

#   source_path = [{
#     path             = "${path.module}/src"
#     patterns         = ["!requirements.txt"]
#     pip_requirements = true
#   }]

#   timeout = 60
#   publish = true

#   tracing_mode          = "Active"
#   attach_tracing_policy = true

#   attach_policy_json = true
#   policy_json        = data.aws_iam_policy_document.associations_export_lambda_policy.json

#   event_source_mapping = {
#     dynamodb = {
#       event_source_arn  = var.associations_ddb_stream_arn
#       starting_position = "TRIM_HORIZON"
#     }
#   }

#   allowed_triggers = {
#     dynamodb = {
#       principal  = "dynamodb.amazonaws.com"
#       source_arn = var.associations_ddb_stream_arn
#     }
#   }
# }

# #Bucket for Athena query results
# #tfsec:ignore:aws-s3-enable-bucket-logging
# #tfsec:ignore:aws-s3-enable-versioning
# resource "aws_s3_bucket" "athena_results_bucket" {
#   bucket_prefix = "associations-athena-results-${var.environment_name}-"
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }

#   force_destroy = true

#   lifecycle_rule {
#     abort_incomplete_multipart_upload_days = 7
#     enabled                                = true
#     expiration {
#       days = 7
#     }
#   }
# }

# resource "aws_s3_bucket_public_access_block" "athena_results_bucket_block_public" {
#   bucket                  = aws_s3_bucket.athena_results_bucket.id
#   block_public_acls       = true
#   block_public_policy     = true
#   restrict_public_buckets = true
#   ignore_public_acls      = true
# }

# resource "aws_athena_database" "associations_athena_db" {
#   name   = "associations_db"
#   bucket = aws_s3_bucket.athena_results_bucket.id
#   encryption_configuration {
#     encryption_option = "SSE_S3"
#   }
# }

# resource "aws_glue_catalog_table" "associations_glue_catalog_table" {
#   name          = "associations"
#   database_name = aws_athena_database.associations_athena_db.name
#   table_type    = "EXTERNAL_TABLE"

#   parameters = {
#     EXTERNAL = "TRUE"
#   }

#   storage_descriptor {
#     location      = "s3://${aws_s3_bucket.associations_bucket.id}/"
#     input_format  = "org.apache.hadoop.mapred.TextInputFormat"
#     output_format = "org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat"

#     ser_de_info {
#       name                  = "json-serde"
#       serialization_library = "org.openx.data.jsonserde.JsonSerDe"
#     }

#     columns {
#       name = "associationId"
#       type = "string"
#     }

#     columns {
#       name = "username"
#       type = "string"
#     }

#     columns {
#       name = "userId"
#       type = "string"
#     }

#     columns {
#       name = "startTime"
#       type = "string"
#     }

#     columns {
#       name = "endTime"
#       type = "string"
#     }

#     columns {
#       name = "burnerAccountId"
#       type = "string"
#     }

#     columns {
#       name = "grouplead"
#       type = "string"
#     }

#   }
# }
