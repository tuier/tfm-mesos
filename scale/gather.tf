# gather algo
resource "aws_iam_role_policy" "node_gather" {
  name = "${var.cluster_name}_node_gather"
  role = "${aws_iam_role.node_gather.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "node_gather" {
  name = "${var.cluster_name}_node_gather"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "node_gather" {
  filename      = "${path.module}/src/build/lambda-node_gather.zip"
  function_name = "${var.cluster_name}_node_gather"
  role          = "${aws_iam_role.node_gather.arn}"
  handler       = "${var.node_gather_handler}"
  runtime       = "python2.7"
  timeout       = 20
  memory_size   = 512

  vpc_config {
    subnet_ids         = ["${split(",",var.subnets)}"]
    security_group_ids = ["${var.security_group}"]
  }

  depends_on = ["null_resource.build"]
}
