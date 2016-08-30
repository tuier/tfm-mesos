# Input Variable

## Global
* cluster_name: Name of the cluster (must be unique per region)
* region: AWS region to setup the cluster
* azs_name: Availability zones across to setup the cluster (default:all from 
		the region)
* azs_count: Number of Availability zones you want to use for the setup.
* network_number: unique ip cluster identifier must be between 1-254,
	 	to match 10.<num>.0.0/16 CIDR

##VPC

* bastion_extra_user_data: Extra user data to use in the bastion

## Zookeeper

* zookeeper_ami: AMI for Zookeeper instance
* instance_type_zookeeer: Type of amazon instance use to run Zookeeper
* zookeeper_capacity: number of desired instance in the initialisation of ASG
* zookeeper_extra_user_data: Extra user data to use in the bastion

## Mesos master

* mesos_master_ami: AMI for Mesos master instance
* instance_type_master: Type of amazon instance use to run Mesos master
* master_capacity: number of desired instance in the initialisation of ASG
* master_extra_user_data: Extra user data to use in the Mesos master

## Mesos agent

* mesos_agent_ami:AMI for Mesos agent instance
* instance_type_agent:Type of amazon instance use to run Mesos agent
* agent_min_capacity: number of desired instance in the initialisation of ASG
* agent_extra_user_data: Extra user data to use in the Mesos agent

## Access

* aws_key_name:amazon ssh key to use during setup of all instance

## DNS

* route_zone_id: Zone id where to create sub-domain (based on name of the 
		cluster
* fqdn: First level domain where to create sub-domain

## AUTO SCALE

* node_gather_handler: name of the handle with the form 
<module>.<function_handler>
* node_process_handler: name of the handle with the form 
<module>.<function_handler>
* nnode_scale_handler: name of the handle with the form 
<module>.<function_handler>
* scale_up_threshold: percent over will scale up
* scale_down_threshold: percent under will scale down
* mem_resource: total memory per node
* cpu_resource:total cpu per node

## TAGS

* tag_product: when setup, a product tag, with that value, is setup on all 
resources.
* tag_purpose: when setup, a purpose tag, with that value, is setup on all 
resources.
