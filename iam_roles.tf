#Lambda
resource "aws_iam_role" "daemon_lambda_lambda_role" {
  name               = "daemon-lambda"
  assume_role_policy = data.aws_iam_policy_document.daemon_lambda_lambda_assume_role.json
}


data "aws_iam_policy_document" "daemon_lambda_lambda_assume_role" {

  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "daemon_lambda_lambda_role_attachment" {
  role       = aws_iam_role.daemon_lambda_lambda_role.name
  policy_arn = aws_iam_policy.daemon_lambda_policy.arn
}
