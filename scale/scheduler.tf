# scheduling
resource "aws_cloudwatch_event_rule" "scheduler" {
  name                = "${var.cluster_name}_scheduler_lambda-5min_node"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "scheduler" {
  rule      = "${aws_cloudwatch_event_rule.scheduler.name}"
  target_id = "${var.cluster_name}_SendToLambda-scheduler_node"
  arn       = "${aws_lambda_function.node_gather.arn}"

  input = <<EOF
{
  "mesos_master":"${var.mesos_master}",
  "sns_process":"${aws_sns_topic.process.arn}",
  "sns_scale" :"${aws_sns_topic.node_scale.arn}",
  "scale_up_threshold": "${var.scale_up_threshold}",
  "scale_down_threshold": "${var.scale_down_threshold}",
  "min_node": "${var.agent_min_capacity}",
  "mem_resource": "${var.mem_resource}",
  "cpu_resource": "${var.cpu_resource}",
  "asg_name":"${var.mesos_node}"
}
EOF
}

resource "aws_lambda_permission" "scheduler" {
  statement_id  = "${var.cluster_name}_node_scheduler"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.node_gather.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.scheduler.arn}"
}
