resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "pip install -r scripts/function_python/requirements.txt -t scripts/function_python/"
  }

  triggers = {
    dependencies_versions = filemd5("scripts/function_python/requirements.txt")
    source_versions       = filemd5("scripts/function_python/lambda_function.py")
  }
}

data "archive_file" "daemon_ml_ai_sc_lambda_zip" {
  type        = "zip"
  source_dir  = "./scripts/function_python/"
  output_path = "./scripts/lambda_function.zip"
  depends_on  = [null_resource.install_dependencies]
}

resource "aws_lambda_function" "daemon_ml_ai_sc_lambda" {
  function_name = "lambda-layers-test"
  role          = aws_iam_role.daemon_lambda_lambda_role.arn
  description   = "lambda-layers-test"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.7"
  timeout       = "300"

  filename         = data.archive_file.daemon_ml_ai_sc_lambda_zip.output_path
  source_code_hash = data.archive_file.daemon_ml_ai_sc_lambda_zip.output_base64sha256

  environment {
    variables = {
      "S3_BUCKET_NAME" = var.data_storage_bucket_name
    }
  }

  layers = [
    aws_lambda_layer_version.daemon_ml_ai_lambda_layer.arn
  ]
}
