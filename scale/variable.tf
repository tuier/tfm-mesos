#global
variable "cluster_name" {
  default     = ""
  description = "Name of the cluster (must be uniq per region)"
}

variable "security_group" {
  default     = ""
  description = "Security Group to access Mesos Cluster"
}

variable "subnets" {
  default     = ""
  description = "Subnets of The cluster"
}

# lambda setup
variable "node_gather_handler" {
  default     = "node_gather.lambda_handler"
  description = "lambda handler for gather function"
}

variable "node_process_handler" {
  default     = "node_process.lambda_handler"
  description = "lambda handler for process function"
}

variable "node_scale_handler" {
  default     = "node_scale.lambda_handler"
  description = "lambda handler for scale function"
}

# lambda configuration
variable "scale_down_threshold" {
  default     = "40"
  description = "Threashold in % to trigger a scale down"
}

variable "scale_up_threshold" {
  default     = ""
  description = "Threashold in % to trigger a scale up"
}

variable "cpu_resource" {
  default     = "8"
  description = "Number of cpu per Node"
}

variable "mem_resource" {
  default     = "15"
  description = "Number of mem per Node"
}

variable "agent_min_capacity" {
  default     = "1"
  description = "Minimum number of agent that the cluster must not get lower"
}

variable "mesos_master" {
  default     = "mesos-master"
  description = "Fqdn of the mesos-master endpoint"
}

variable "mesos_node" {
  default     = ""
  description = "Name of the ASG for node"
}
