provider "aws" {
  region = "eu-west-1"
}

module "mesos" {
  source = "github.com/tuier/terraform-mesos-module"

  # cluster
  cluster_name   = "sample"
  region         = "eu-west-1"
  network_number = 42

  #zookeeper
  zookeeper_ami          = "ami-********"
  instance_type_zookeeer = "m3.medium"
  zookeeper_capacity     = "3"

  #mesos master
  mesos_master_ami     = "ami-********"
  instance_type_master = "m3.medium"
  master_capacity      = "1"

  #mesos agent
  mesos_agent_ami     = "ami-********"
  instance_type_agent = "c4.xlarge"
  agent_min_capacity  = "2"

  # access related
  aws_key_name = "${var.aws_key_name}"

  # dns related
  route_zone_id = "************"
  fqdn          = "****.fqdn.tld"

  #auto scale
  scale_up_threshold   = "90"
  scale_down_threshold = "80"
  mem_resource         = "15"
  cpu_resource         = "8"

  tag_product = "product-web-cluster"
  tag_purpose = "purpose_test"
}
