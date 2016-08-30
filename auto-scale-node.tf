module "node_scale" {
  source         = "scale"
  cluster_name   = "${var.cluster_name}"
  security_group = "${aws_security_group.mesos.id}"
  subnets        = "${module.vpc.subnets_private}"

  node_process_handler = "${var.node_process_handler}"
  node_scale_handler   = "${var.node_scale_handler}"
  node_gather_handler  = "${var.node_gather_handler}"

  scale_down_threshold = "${var.scale_down_threshold}"
  mem_resource         = "${var.mem_resource}"
  scale_up_threshold   = "${var.scale_up_threshold}"
  agent_min_capacity   = "${var.agent_min_capacity}"
  cpu_resource         = "${var.cpu_resource}"
  mesos_node           = "${aws_autoscaling_group.mesos-agent.name}"
  mesos_master         = "${aws_route53_record.mesos-master.fqdn}"
}
