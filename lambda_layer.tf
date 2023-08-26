locals {
  layer_zip_path = "layer.zip"
  layer_name     = "my_lambda_requirements_layer"
}

resource "null_resource" "daemon_ml_ai_lambda_layer" {
  provisioner "local-exec" {
    command = "pip install -r scripts/python_extensions/requirements.txt -t scripts/python_extensions/extensions/lib"
  }
}

data "archive_file" "daemon_ml_ai_scripts_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/scripts/python_extensions/"
  output_path = "${path.module}/scripts/${local.layer_zip_path}"
  depends_on  = [null_resource.daemon_ml_ai_lambda_layer]
}

# create lambda layer from s3 object
resource "aws_lambda_layer_version" "daemon_ml_ai_lambda_layer" {
  s3_bucket           = aws_s3_bucket.lambda_layer_bucket.id
  s3_key              = aws_s3_object.lambda_layer_zip.key
  layer_name          = local.layer_name
  compatible_runtimes = ["python3.7"]
  skip_destroy        = true
  depends_on          = [aws_s3_object.lambda_layer_zip]
}
