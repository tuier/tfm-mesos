#!/bin/env python2
# -*- coding: utf-8 -*-
"""
This script is use process metric from mesos cluster
Using the current usage of the cluster

"""
import sys
import logging
import json

import boto3


logging.basicConfig(stream=sys.stderr, level=logging.INFO)


def lambda_handler(event, dummy_contest):
    """
        main function who is the entry point to the lambda function
        message from sns must contain:
        unallocated: list of resource unallocated by the format (cpu,mem)
        biggest: list of resource allocated by the format (cpu,mem) which
        correspond to task size
        cpu_allocated: allocated percent of CPU in the whole cluster
        meme_allocated: allocated percent of Memory in the whole cluster
        sns_scale: topic arn for the scale lambda function
        asg_name: name of the ASG you want to scale
        scale_up_threshold: percentage threshold to scale up
        scale_down_threshold: percentage threshold to scale down
        mem_resource: memory resource added by one node
        cpu_resource: cpu resource added by one node
        app_capacity_percent: extra capacity for application (in percent)
        min_node: number of node you want to keep at all time
    """
    try:
        config = json.loads(event['Records'][0]['Sns']['Message'])
        logging.warning(config)
        resource = config['unallocated']
        result = algo(
            config['list_tasks'],
            int(config['cpu_resource']),
            int(config['mem_resource']),
            State(
                resource,
                (
                    float(config['cpu_allocated']),
                    float(config['mem_allocated'])
                ),
                float(config['scale_up_threshold']),
                float(config['scale_down_threshold'])
            ),
            config['app_capacity']
        )
        logging.warning("trying to scale %d node(s)", result)
        asg_name = config["asg_name"]
        if result != 0:
            sns_scale = config["sns_scale"]
            client = boto3.client('sns')
            client.publish(
                TopicArn=sns_scale,
                Message=json.dumps(
                    {
                        'asg_name': asg_name,
                        'scale_num': result,
                        "min_node": config['min_node']
                    }),
                MessageStructure='strings',
            )
        logging.warning("%s %d", asg_name, result)
    except KeyError as keyerr:
        logging.warning(
            "Received: %s \n error: %s",
            json.dumps(event),
            keyerr
        )


def algo(tasks, cpu_resource, mem_resource, state, app_capacity):
    """
        given a unused resource, the cpu and memory needed to scales up task
        and the percentage of resource used in the cluster
        this will make the decision to add new node to the cluster

        :param resources: list of cpu and memory unused in the cluster
        :type resource: list of tuple
        :param tasks: list of task
        :type tasks: [ {"resource":(float(cpu),float(mem)),
            "count":int(number of task),"id":string(id of the task)}]
        :param cpu_resource: cpu per new node
        :type cpu_resource: int
        :param mem_resource: memory per new node
        :type mem_resource: int
        :param state: state of the cluster
        :type state: State
        :param app_capacity: extra capacity for application (in percent)
        :type app_capacity: int

        :return: the number of instance to add or remove (negative)
        :rtype: int
    """
    # resource percent based scaling down
    while state.must_scale_down():
        state.remove_node(1)
    logging.warning("from decreasing part => %d node(s)", state.get_scale())

    for task in tasks:
        cpu_task = task["resources"][0]
        mem_task = task["resources"][1]
        task_count = 0
        # number of task we can put on a empty server
        count = 1 + int((app_capacity / 100) * task['count'])

        # for each node add the number of tasks you can fit in the unused
        # resource
        for resource in state.resources:
            task_count += max(min(
                int(resource[0] / cpu_task),
                int(resource[1] / mem_task)
            ), 0)

        if task_count < count:
            # the number of node we need to add based on remaining task
            task_full = max(cpu_resource / cpu_task, mem_resource / mem_task)
            state.add_node(1 + int(count - task_count / task_full))
        logging.warning("task scaling %d", state.get_scale())

    # resource percent based scaling up
    while state.must_scale_up():
        state.add_node(1)

    logging.warning("from increasing part => %d node(s)", state.get_scale())

    return state.get_scale()


class State(object):

    """
    state of the cluster with scale up and down function,
    simple boolean function to scale up or down from percent
    """

    def __init__(self, resources, percent, scale_up, scale_down):
        self.resources = resources
        self.num_node = len(resources)
        self.cpu_percent = percent[0]
        self.mem_percent = percent[1]
        self.init_node = self.num_node
        self.scale_up_threshold = scale_up
        self.scale_down_threshold = scale_down

    def add_node(self, num):
        """
        add node to the struct passed in parameter and calculate the new
        used percentage

        """
        for _ in range(num):
            self.resources.append((self.cpu_percent, self.mem_percent))
        self.num_node += num
        for _ in range(num):
            self.cpu_percent -= 100.0 / float(self.num_node)
            self.mem_percent -= 100.0 / float(self.num_node)

    def remove_node(self, num):
        """
        remove node to the struct passed in parameter and calculate the new
        used percentage
        """
        # remove node ? from self.resources
        self.num_node -= num
        for _ in range(num):
            self.cpu_percent += 100.0 / float(self.num_node)
            self.mem_percent += 100.0 / float(self.num_node)

    def get_scale(self):
        """
        return the number of Node should be added up to the cluster

        :return : number of node the cluster should scale
        :rtype: int
        """
        return self.num_node - self.init_node

    def must_scale_up(self):
        """
        :return : return if the cluster must be scaled up
        :rtype : bool
        """
        return self.cpu_percent > self.scale_up_threshold or \
            self.mem_percent > self.scale_up_threshold

    def must_scale_down(self):
        """
        :return : return if the cluster must be scaled down
        :rtype : bool
        """
        return self.num_node > 1 and \
            self.cpu_percent < self.scale_down_threshold and \
            self.mem_percent < self.scale_down_threshold
