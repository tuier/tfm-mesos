provider "aws" {
  region = "${var.region}"
}

#VPC

module "vpc" {
  source       = "github.com/tuier/terraform-vpc-module"
  cluster_name = "${var.cluster_name}"
  region       = "${var.region}"
  azs_count    = "${var.azs_count}"

  #	azs_name = "${var.azs_name}"
  aws_key_name = "${var.aws_key_name}"

  # dns
  fqdn           = "${var.cluster_name}.${var.fqdn}"
  route_zone_id  = "${var.route_zone_id}"
  network_number = "${var.network_number}"

  # extra user data
  user_data   = "${var.bastion_extra_user_data}"
  tag_product = "${var.tag_product}"
  tag_purpose = "${var.tag_purpose}"
}

# DNS
resource "aws_route53_zone" "cluster_mesos" {
  name    = "${var.cluster_name}.${var.fqdn}"
  vpc_id  = "${module.vpc.id}"
  comment = "${var.cluster_name}"

  tags {
    Name    = "${var.cluster_name}.${var.fqdn}"
    product = "${var.tag_product}"
    purpose = "${var.tag_purpose}"
    builder = "terraform"
  }
}

resource "aws_route53_record" "ns_cluster" {
  name    = "${var.cluster_name}"
  zone_id = "${var.route_zone_id}"
  type    = "NS"
  ttl     = 30

  records = [
    "${aws_route53_zone.cluster_mesos.name_servers.0}",
    "${aws_route53_zone.cluster_mesos.name_servers.1}",
    "${aws_route53_zone.cluster_mesos.name_servers.2}",
    "${aws_route53_zone.cluster_mesos.name_servers.3}",
  ]
}

# S3
resource "aws_s3_bucket" "create_s3" {
  bucket        = "${var.cluster_name}.${var.fqdn}"
  policy        = "${data.template_file.s3_policy.rendered}"
  force_destroy = true

  tags {
    Name    = "${var.cluster_name}.${var.fqdn}"
    product = "${var.tag_product}"
    purpose = "${var.tag_purpose}"
    builder = "terraform"
  }

  versioning {
    enabled = true
  }
}

data "template_file" "s3_policy" {
  vars {
    vpc_id      = "${module.vpc.id}"
    bucket_name = "${var.cluster_name}.${var.fqdn}"
  }

  template = "${file("${path.module}/templates/s3_policy.tpl")}"
}
