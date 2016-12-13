#global
variable "cluster_name" {
  default     = ""
  description = "Name of the cluster (must be uniq per region)"
}

variable "region" {
  default     = ""
  description = "AWS region to setup the cluster"
}

# network
variable "azs_name" {
  default     = ""
  description = "Availability zones across to setup the cluster (default all from the region)"
}

variable "azs_count" {
  default = 3
}

variable "network_number" {
  default     = "200"
  description = "unique ip cluster identifier must be between 1-254, to match 10.<num>.0.0/16 CIDR"
}

variable "bastion_extra_user_data" {
  default     = ""
  description = "extra configuration for user data"
}

#zookeeper
variable "zookeeper_ami" {
  default     = ""
  description = "AMI for zookeeper instance"
}

variable "zookeeper_instance_type" {
  default     = ""
  description = "Type of amazon instance use to run zookeeper"
}

variable "zookeeper_capacity" {
  default     = "3"
  description = "number of desired instance in the initialisation of ASG"
}

variable "zookeeper_extra_user_data" {
  default     = ""
  description = "extra configuration for user data"
}

#mesos master
variable "master_ami" {
  default     = ""
  description = "AMI for mesos-master instance"
}

variable "master_instance_type" {
  default     = ""
  description = "Type of amazon instance use to run mesos-master"
}

variable "master_capacity" {
  default     = "3"
  description = "number of desired instance in the initialisation of ASG"
}

variable "master_extra_user_data" {
  default     = ""
  description = "extra configuration for user data"
}

#mesos agent
variable "agent_ami" {
  default     = ""
  description = "AMI for mesos-agent instance"
}

variable "agent_instance_type" {
  default     = ""
  description = "Type of amazon instance use to run mesos-agent"
}

variable "agent_min_capacity" {
  default     = "3"
  description = "number of desired instance in the initialisation of ASG"
}

variable "agent_max_capacity" {
  default     = "30"
  description = "max number of instance in the ASG"
}

variable "agent_extra_user_data" {
  default     = ""
  description = "extra configuration for user data"
}

# access related 
variable "aws_key_name" {
  default     = ""
  description = "amazon ssh key to use during setup of all instance"
}

# dns related 
variable "route_zone_id" {
  default     = ""
  description = "Zone id where to create subdomain (based on name of the cluster)"
}

variable "fqdn" {
  default     = ""
  description = "First level domain where to create subdomain"
}

# Tags
variable "tag_product" {
  default     = "mesos"
  description = "when setup a product tag is setup on all resources, except agent , with that value"
}

variable "tag_product_agent" {
  default     = "mesos"
  description = "when setup a product tag is setup on all agent, with that value"
}

variable "tag_purpose" {
  default     = "test"
  description = "when setup a purpose tag is setup on all resources, with that value"
}
