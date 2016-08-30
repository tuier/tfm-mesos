#mesos agent 

resource "aws_autoscaling_group" "mesos-agent" {
  name     = "${var.cluster_name}_mesos-agent"
  max_size = 100
  min_size = "${var.agent_min_capacity}"

  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.mesos-agent.name}"
  vpc_zone_identifier       = ["${split(",",module.vpc.subnets_private)}"]

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}_mesos-agent"
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
    ignore_changes        = ["load_balancers", "desired_capacity"]
  }
}

resource "aws_launch_configuration" "mesos-agent" {
  name_prefix          = "${var.cluster_name}_mesos-agent"
  image_id             = "${var.mesos_agent_ami}"
  instance_type        = "${var.instance_type_agent}"
  iam_instance_profile = "${aws_iam_instance_profile.agent_profile.name}"
  key_name             = "${var.aws_key_name}"
  security_groups      = ["${aws_security_group.mesos.id}"]

  user_data = "${template_file.launch_mesos_agent.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    #		device_name = "mesos-agent"
    volume_size = 50
  }
}

resource "aws_iam_role" "agent_role" {
  name = "${var.cluster_name}_agent_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
	{
	  "Action": "sts:AssumeRole",
	  "Principal": {
		"Service": "ec2.amazonaws.com"
	  },
	  "Effect": "Allow",
	  "Sid": ""
	}
  ]
}
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "agent_profile" {
  name  = "${var.cluster_name}_agent_profile"
  roles = ["${aws_iam_role.agent_role.name}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "agent_policy" {
  name = "${var.cluster_name}_agent_policy"
  role = "${aws_iam_role.agent_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
	{
	  "Effect": "Allow",
	  "Action": [
		"ecr:GetAuthorizationToken",
		"ecr:BatchCheckLayerAvailability",
		"ecr:GetDownloadUrlForLayer",
		"ecr:GetRepositoryPolicy",
		"ecr:DescribeRepositories",
		"ecr:ListImages",
		"ecr:BatchGetImage",
		"logs:CreateLogStream",
		"logs:CreateLogGroup",
		"logs:PutLogEvents"
	  ],
	  "Resource": "*"
	}
  ]
}
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "template_file" "launch_mesos_agent" {
  lifecycle {
    create_before_destroy = true
  }

  vars {
    cluster_name = "${var.cluster_name}"
    fqdn         = "${var.cluster_name}.${var.fqdn}"
  }

  template = "${file("${path.module}/templates/mesos_agent_user_data.tpl")}\n${var.agent_extra_user_data}"

  lifecycle {
    create_before_destroy = true
  }
}
