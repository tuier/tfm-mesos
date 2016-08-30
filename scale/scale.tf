# asg scale
resource "aws_iam_role_policy" "node_scale" {
  name = "${var.cluster_name}_node_scale"
  role = "${aws_iam_role.node_scale.id}"

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
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeScalingActivities",
                "autoscaling:SetDesiredCapacity"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "node_scale" {
  name = "${var.cluster_name}_node_scale"

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

resource "aws_lambda_function" "node_scale" {
  filename      = "${path.module}/src/build/lambda-node_scale.zip"
  function_name = "${var.cluster_name}_node_scale"
  role          = "${aws_iam_role.node_scale.arn}"
  handler       = "${var.node_scale_handler}"
  runtime       = "python2.7"
  timeout       = 3
  depends_on    = ["null_resource.build"]
}

resource "aws_lambda_permission" "node_scale" {
  statement_id  = "${var.cluster_name}_node_scale"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.node_scale.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.node_scale.arn}"
}

resource "aws_sns_topic" "node_scale" {
  name = "${var.cluster_name}_node_scale"
}

resource "aws_sns_topic_subscription" "node_scale" {
  topic_arn = "${aws_sns_topic.node_scale.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.node_scale.arn}"
}
