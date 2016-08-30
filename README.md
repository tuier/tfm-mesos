

This Terraform configuration is meant to install on AWS a full Mesos cluster 
from scratch.


# VPC

The VPC module is require to run this Terraform configuration

# Route53 Zone

A AWS Route53 Zone is create with the name  *<cluster-name>.<top_fqdn>*
Nothing else than the NS is create at that point in the zone.

Later some entry will add two sub-domain: mesos-master and zookeeper to connect 
to both cluster, through ELB, respectively.

# S3 Bucket

A bucket is created with the name *<cluster-name>.<top_fqdn>*.

As the VPC module create a endpoint for S3 there will be no need to handle 
access from server within the VPC

## Policy

When creating the bucket a specific policy is created to allow access only from 
within the VPC

# Mesos Master

## ASG

At boot the cluster name and the Zookeeper endpoint is setup in Mesos 
configuration.

When Auto scaling, the Master will discover other Master through Zookeeper.

## AWS ressource

An ELB is create accessible through Route53 entry at 
`mesos-master.<cluster_name>.<top_fqdn>` on port 80 or 5050

# Mesos Agent

## ASG

At boot the cluster name and the Zookeeper endpoint is setup in Mesos 
configuration.

When Auto scaling, the agent will discover Masters through Zookeeper.

# Zookeeper

## ASG


At boot the cluster name and the s3 exhibitor configuration is set to allow 
zookeeper to gather the shared configuration.

When Auto scaling, the agent will discover Zookeeper through the s3 shared 
configuration.

### Auto Discovery

At boot exhibitor will gather the shared configuration and auto configure 
Zookeeper to connect to the cluster.

## AWS ressource

An ELB is create accessible through Route53 entry at 
`zookeeper.<cluster_name>.<top_fqdn>` on port 2181 and exhibitor at 8080 or 80


# AMI

Some sample ami are available on the "packer" directory


# Auto Scaling


this auto scaling part is in the [scale](scale)  directory

## Lambda 

* Auto scaling use AWS lambda as a scheduled run and execute some python code to:
** gather metric
** process metric
** scale node


## Build

A Terraform resource is meant to build the node part of the submodule before
using it, any change should be re-build and re-push when done that.

## Design

See README from the Auto Scale Repo


## Destroy

When destroying a ENI will be left behind by the lambda who had access to VPC, 
	 and this mean tht the subnet will not be destory until that is remove.

This is a bug and will be probably fixed by Terraform,
	 https://github.com/hashicorp/terraform/issues/5767
# How to use

Some sample terraform configuration is in the [sample](sample) directory and 
the Variable are described in [Variable](VARIABLE.md)
