#global
variable "cluster_name" {
  default     = ""
  description = "Name of the cluster (must be uniq per region)"
}

variable "region" {
  default     = ""
  description = "AWS region to setup the cluster"
}

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

variable "instance_type_zookeeer" {
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
variable "mesos_master_ami" {
  default     = ""
  description = "AMI for mesos-master instance"
}

variable "instance_type_master" {
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
variable "mesos_agent_ami" {
  default     = ""
  description = "AMI for mesos-agent instance"
}

variable "instance_type_agent" {
  default     = ""
  description = "Type of amazon instance use to run mesos-agent"
}

variable "agent_min_capacity" {
  default     = "3"
  description = "number of desired instance in the initialisation of ASG"
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

#auto scale
variable "node_gather_handler" {
  default     = ""
  description = "name of the handle witht the form <module>.<function_handler>"
}

variable "node_process_handler" {
  default     = ""
  description = "name of the handle witht the form <module>.<function_handler>"
}

variable "node_scale_handler" {
  default     = ""
  description = "name of the handle witht the form <module>.<function_handler>"
}

variable "scale_up_threshold" {
  default     = "80"
  description = "percent over will scale up"
}

variable "scale_down_threshold" {
  default     = "40"
  description = "percent under will scale down"
}

variable "mem_resource" {
  default     = "32"
  description = "total memory per node"
}

variable "cpu_resource" {
  default     = "8"
  description = "total cpu per node"
}

variable "tag_product" {
  default     = "mesos"
  description = "when setup a product tag is setup on all resources, with that value"
}

variable "tag_purpose" {
  default     = "test"
  description = "when setup a purpose tag is setup on all resources, with that value"
}
