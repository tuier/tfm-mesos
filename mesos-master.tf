# master 

resource "aws_elb" "mesos-master" {
  name = "${var.cluster_name}-master"

  listener {
    instance_port     = 5050
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  listener {
    instance_port     = 5050
    instance_protocol = "HTTP"
    lb_port           = 5050
    lb_protocol       = "HTTP"
  }

  security_groups             = ["${aws_security_group.mesos.id}", "${module.vpc.sg_bastion}"]
  subnets                     = ["${split(",",module.vpc.subnets_private)}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 3600
  connection_draining         = true
  connection_draining_timeout = 60
  internal                    = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 2
    target              = "HTTP:5050/"
    interval            = 10
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    product = "${var.tag_product}"
    purpose = "${var.tag_purpose}"
    builder = "terraform"
  }
}

resource "aws_route53_record" "mesos-master" {
  name    = "mesos-master"
  zone_id = "${aws_route53_zone.cluster_mesos.zone_id}"
  type    = "CNAME"
  records = ["${aws_elb.mesos-master.dns_name}"]
  ttl     = 300
}

resource "aws_autoscaling_group" "mesos-master" {
  name     = "${var.cluster_name}_mesos-master"
  max_size = 9
  min_size = 1

  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.mesos-master.name}"
  vpc_zone_identifier       = ["${split(",",module.vpc.subnets_private)}"]
  load_balancers            = ["${aws_elb.mesos-master.name}"]
  desired_capacity          = "${var.master_capacity}"

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}_mesos-master"
    propagate_at_launch = true
  }

  tag {
    key                 = "builder"
    value               = "terraform"
    propagate_at_launch = true
  }

  tag {
    key                 = "cluster"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "product"
    value               = "${var.tag_product}"
    propagate_at_launch = true
  }

  tag {
    key                 = "purpose"
    value               = "${var.tag_purpose}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# TODO generate role here 

#

resource "aws_launch_configuration" "mesos-master" {
  name_prefix     = "${var.cluster_name}_mesos-master_"
  image_id        = "${var.master_ami}"
  instance_type   = "${var.master_instance_type}"
  key_name        = "${var.aws_key_name}"
  security_groups = ["${aws_security_group.mesos.id}"]

  lifecycle {
    create_before_destroy = true
  }

  user_data = "${data.template_file.launch_mesos_master.rendered}"
}

data "template_file" "launch_mesos_master" {
  vars {
    cluster_name = "${var.cluster_name}"
    fqdn         = "${var.cluster_name}.${var.fqdn}"
  }

  template = "${file("${path.module}/templates/mesos_master_user_data.tpl")}\n${var.master_extra_user_data}"
}
