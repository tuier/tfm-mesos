# process algo
resource "aws_iam_role" "node_process" {
  name = "${var.cluster_name}_node_process"

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

resource "aws_iam_role_policy" "node_process" {
  name = "${var.cluster_name}_node_process"
  role = "${aws_iam_role.node_process.id}"

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
        }
    ]
}
EOF
}

resource "aws_lambda_function" "node_process" {
  filename      = "${path.module}/src/build/lambda-node_process.zip"
  function_name = "${var.cluster_name}_node_process"
  role          = "${aws_iam_role.node_process.arn}"
  handler       = "${var.node_process_handler}"
  runtime       = "python2.7"
  timeout       = 10
  memory_size   = 512

  depends_on = ["null_resource.build"]
}

resource "aws_lambda_permission" "process" {
  statement_id  = "${var.cluster_name}_node_process"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.node_process.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.process.arn}"
}

resource "aws_sns_topic" "process" {
  name = "${var.cluster_name}_node_process"
}

resource "aws_sns_topic_subscription" "process" {
  topic_arn = "${aws_sns_topic.process.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.node_process.arn}"
}
