# Lambda Scale

This repo is meant to be used with mesos and marathon setup, it has two 
different parts: auto scaling node.

In both cases the Makefile will:
- create a python environment
- install the neccessery dependencies
- create a zip that we can push to Lambda.

# Design

The lambda is meant to be used periodically (for exemple with Cloudwatch 
		scheduler). and all Lambda will communicate with the next lambda 
function with SNS.

It will work with 3 different parts for both kinds of scaling.
1. a gathering lambda to retrive the metrics from different sources
2. a processer who will process the metrics gathered and send to the last lambda
the information to scale the Node
3. a lambda to perform the scaling

```

                          .--------.             .---------.             .-------.
                          |        |             |         |             |       |
[ CloudWatch Trigger ]--->| gather |--->[SNS]--->| process |--->[SNS]--->| scale |
                          |        |             |         |             |       |
                          '--------'             '---------'             '-------'
```
# Dependencies

Tox (python-tox) is needed as  dependency of the building process. It's used to 
create the python environment.

# Build

A simple
```
make all
```
will build everything and create a zip package for lambda with the python 
environment.

You can add more granularity by only building a specific part with
```
make <part>
```
with parts: `node_scale`, `node_gather`, `node_process`

# Documentation

The documentation can be built with sphynx
```
make docs
```


# Implementation Docs

More information about the implementation can be found on the next 
documentation link 

## Gather

The gather lambda function gather some metric from the snapshot of the Mesos
 master state and from that create a global view of task in the cluster with
 number of task and number of resource per task


## Process

The process function will calculate, with the data in the SNS, if we need to
scale up or down.

This algorithm to scale is really complex and most certainly not perfect.

At the moment there is two way of scaling, by usage of the whole cluster
 (percent of Memory or CPU), by Application usage


The Application usage scale goes like this:
	Considerer a parameter X who mean to scale X% of the Application
	From the list of task find the total amount of resource used by all Application 
	(total of Task)
	If the cluster can't hold X% of every Application, add a Agent until you 
	reach X% 

The main Algorithm goes like this:

	First you check if from the percent we need to scale down

	Application usage scale up

	And after that check if we need to scale up more per percent aka if after scale
	up or down we are above the maximum threshold scale up until we are under it


## Scale

The scale process will calculate the new capacity needed for the ASG (AWS 
		AutoScalingGroup) and try to apply that change
This will fail if another scaling is underway (that can be a problem if a scale
 down is underway and we want to scale up).
