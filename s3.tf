#Lambda Layer
# define existing bucket for storing lambda layers
resource "aws_s3_bucket" "lambda_layer_bucket" {
  bucket = var.layer_bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_layer_bucket" {
  bucket = aws_s3_bucket.lambda_layer_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# upload zip file to s3
resource "aws_s3_object" "lambda_layer_zip" {
  bucket     = aws_s3_bucket.lambda_layer_bucket.id
  key        = "lambda_layers/${local.layer_name}/${local.layer_zip_path}"
  source     = "./scripts/${local.layer_zip_path}"
  depends_on = [data.archive_file.daemon_ml_ai_scripts_lambda_zip]
}

#Lambda Output Lambda Storage S3 bucker
resource "aws_s3_bucket" "lambda_data_storage" {
  bucket = var.data_storage_bucket_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_data_storage" {
  bucket = aws_s3_bucket.lambda_data_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}