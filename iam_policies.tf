data "aws_iam_policy_document" "daemon_lambda_policy" {
  statement {
    sid = "EC2"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
    ]
    resources = ["*"]
  }

  statement {
    sid = "S3"

    actions = [
      "S3:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "daemon_lambda_policy" {
  name        = "daemon-lambda-policy"
  description = "daemon-lambda-policy"
  policy      = data.aws_iam_policy_document.daemon_lambda_policy.json
}