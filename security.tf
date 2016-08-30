resource "aws_security_group" "mesos" {
  name        = "${var.cluster_name}_mesos"
  description = "Allow all inbound traffic within it"
  vpc_id      = "${module.vpc.id}"

  tags {
    Name    = "${var.cluster_name}_mesos"
    cluster = "${var.cluster_name}"
    product = "${var.tag_product}"
    purpose = "${var.tag_purpose}"
    builder = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "mesos-in" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = "${aws_security_group.mesos.id}"

  security_group_id = "${aws_security_group.mesos.id}"
}

resource "aws_security_group_rule" "mesos-out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.mesos.id}"
}

resource "aws_security_group_rule" "allow_ssh_from_within_vpc" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${module.vpc.cidr_block}"]

  security_group_id = "${aws_security_group.mesos.id}"
}
