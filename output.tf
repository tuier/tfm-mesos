output "agent_asg" {
  value = "${aws_autoscaling_group.mesos-agent.name}"
}

output "sg" {
  value = "${aws_security_group.mesos.id}"
}

output "master_endpoint" {
  value = "${aws_route53_record.mesos-master.fqdn}"
}

output "vpc_subnets_private" {
  value = "${module.vpc.subnets_private}"
}
