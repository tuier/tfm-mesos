# zookeeper

resource "aws_elb" "zookeeper" {
  name = "${var.cluster_name}-zookeeper"

  listener {
    instance_port     = 8080
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  listener {
    instance_port     = 8080
    instance_protocol = "HTTP"
    lb_port           = 8080
    lb_protocol       = "HTTP"
  }

  listener {
    instance_port     = 2181
    instance_protocol = "TCP"
    lb_port           = 2181
    lb_protocol       = "TCP"
  }

  security_groups             = ["${aws_security_group.mesos.id}", "${module.vpc.sg_bastion}"]
  subnets                     = ["${split(",",module.vpc.subnets_private)}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 3600
  connection_draining         = true
  connection_draining_timeout = 10
  internal                    = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 2
    target              = "tcp:2181"
    interval            = 10
  }

  tags {
    product = "${var.tag_product}"
    purpose = "${var.tag_purpose}"
    builder = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "zookeeper" {
  name    = "zookeeper"
  zone_id = "${aws_route53_zone.cluster_mesos.zone_id}"
  type    = "CNAME"
  ttl     = 300
  records = ["${aws_elb.zookeeper.dns_name}"]
}

resource "aws_autoscaling_group" "zookeeper" {
  name     = "${var.cluster_name}_zookeeper"
  max_size = 9
  min_size = "${var.zookeeper_capacity}"

  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.zookeeper.name}"
  vpc_zone_identifier       = ["${split(",",module.vpc.subnets_private)}"]
  load_balancers            = ["${aws_elb.zookeeper.name}"]

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}_zookeeper"
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

resource "aws_iam_role" "zoo_role" {
  name = "${var.cluster_name}_zoo_role"

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

resource "aws_iam_instance_profile" "zoo_profile" {
  name  = "${var.cluster_name}_zoo_profile"
  roles = ["${aws_iam_role.zoo_role.name}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "zoo_policy" {
  name = "${var.cluster_name}_zoo_policy"
  role = "${aws_iam_role.zoo_role.id}"

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
				"s3:AbortMultipartUpload",
				"s3:DeleteObject",
				"s3:GetBucketAcl",
				"s3:GetBucketPolicy",
				"s3:GetObject",
				"s3:GetObjectAcl",
				"s3:ListBucket",
				"s3:ListBucketMultipartUploads",
				"s3:ListMultipartUploadParts",
				"s3:PutObject",
				"s3:PutObjectAcl"
            ],
            "Resource": [
				"*"
            ]
        }
	]
}
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "zookeeper" {
  name_prefix          = "${var.cluster_name}_zookeeper"
  image_id             = "${var.zookeeper_ami}"
  instance_type        = "${var.instance_type_zookeeer}"
  key_name             = "${var.aws_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.zoo_profile.name}"
  user_data            = "${template_file.launch_zookeeper.rendered}"
  security_groups      = ["${aws_security_group.mesos.id}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "template_file" "launch_zookeeper" {
  vars {
    asg_name     = "${var.cluster_name}_zookeeper"
    region       = "${var.region}"
    fqdn         = "${var.cluster_name}.${var.fqdn}"
    cluster_name = "${var.cluster_name}"
  }

  lifecycle {
    create_before_destroy = true
  }

  template = "${file("${path.module}/templates/zookeeper_user_data.tpl")}\n${var.zookeeper_extra_user_data}"
}
