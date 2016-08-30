#!/bin/env python2
# -*- coding: utf-8 -*-
"""
This script is use to auto scale up or down the ASG for Mesos node,
Using the current usage of the cluster

"""
import sys
import logging
import json
import collections

import requests
import boto3

logging.basicConfig(stream=sys.stderr, level=logging.INFO)


MESOS_MASTER_FORMAT = "http://{}/{}"
MESOS_MASTER_STATE = "master/state"


def lambda_handler(event, dummy_contest):
    """
        main function who will get call by the lambda function
        event must contain:
        mesos_master: dns for the mesos master
        sns_process: topic arn for the process lambda function
        sns_scale: topic arn for the scale lambda function
        asg_name: name of the ASG you want to scale
        scale_up_threshold: percentage threshold to scale up
        scale_down_threshold: percentage threshold to scale down
        mem_resource: memory resource added by one node
        cpu_resource: cpu resource added by one node
        min_node: number of node you want to keep at all time
    """
    config = event

    logging.warning(config)

    master_state = get_mesos_master_state(
        MESOS_MASTER_FORMAT.format(
            config['mesos_master'],
            MESOS_MASTER_STATE
        )
    )
    if master_state == {}:
        logging.warning("getting state master failled")
        return
    cpu, mem = get_cluster_usage(master_state)
    result = {
        "list_tasks": list_tasks(master_state),
        "unallocated": get_unalloc_resource(master_state),
        "cpu_allocated": cpu,
        "mem_allocated": mem,
        "sns_scale": config['sns_scale'],
        "asg_name": config['asg_name'],
        "scale_up_threshold": config['scale_up_threshold'],
        "scale_down_threshold": config['scale_down_threshold'],
        "mem_resource": config['mem_resource'],
        "cpu_resource": config['cpu_resource'],
        "app_capacity": config.get('app_capacity', 20),
        "min_node": config['min_node']
    }
    client = boto3.client('sns')
    client.publish(
        TopicArn=config['sns_process'],
        Message=json.dumps(result),
        MessageStructure='strings',
    )
    logging.warning(result)


def get_cluster_usage(mesos_state):
    """
        given a hostname get the percent use of cpu and memory for the whole
        cluster

        :param mesos_leader: address of the leader <ip>:<port>
        :type agent_host: string
        :return: a tuple of the percent use of cpu and memory in the cluster
        :rtype: tuple(float, float)
    """
    total_used_cpu, total_used_mem, total_cpu, total_mem = 0.0, 0.0, 0.0, 0.0
    for fram in mesos_state['frameworks']:
        total_used_cpu += fram['used_resources']['cpus']
        total_used_mem += fram['used_resources']['mem']
        logging.warning(
            "\nid: %s %s\n\t  cpu: %f\n\t  mem:%f",
            fram['name'],
            fram['id'],
            fram['used_resources']['cpus'],
            fram['used_resources']['mem']
        )
    for agent in mesos_state['slaves']:
        total_cpu += agent['resources']['cpus']
        total_mem += agent['resources']['mem']
        logging.warning(
            "\nagent: %s %s \n\t  cpu: %f\n\t  mem:%f",
            agent['hostname'],
            agent['id'],
            agent['resources']['cpus'],
            agent['resources']['mem']
        )
    logging.warning(
        "\nused:\n\t  cpu: %f\n\t  mem:%f\ntotal:\n\t  cpu: %f\n\t  mem:%f",
        total_used_cpu, total_used_mem, total_cpu, total_mem
    )
    return (
        float(total_used_cpu * 100 / total_cpu),
        float(total_used_mem * 100 / total_mem)
    )


def get_mesos_master_state(url):
    """
        Will request the master dns for the cluster, if it's not the leader
                it will do a second request to the leader

        :return: state of the master
        :rtype: dict
    """
    req_state = requests.get(url)
    if req_state.ok:
        master_state = req_state.json()
        if len(master_state['slaves']) > 0:
            return master_state
        # not the leader
        leader = master_state['leader'].split('@')[1]
        leader_state = requests.get(
            MESOS_MASTER_FORMAT.format(
                leader,
                MESOS_MASTER_STATE
            )
        )
        if leader_state.ok:
            return leader_state.json()
    else:
        logging.warning(req_state)
    return {}


def list_tasks(master_state):
    """
        given a mesos master-state get the highest usage of cpu and memory
        for all tasks

        :param master_state: master-state from /master/state
        :type master_state: dict
        :return: a tuple of the highest usage of cpu and memory
        :rtype: tuple(float, float)
    """
    resources = {}
    number_tasks = collections.defaultdict(int)
    for fram in master_state['frameworks']:
        for task in fram['tasks']:
            if 'management' not in task['id']:
                resources[task['id']] = (
                    float(task['resources']['cpus']),
                    float(task['resources']['mem'])
                )
                number_tasks[task['id']] += 1

    tasks = []
    for key in resources.keys():
        tasks.append({
            "id": key,
            "resources": resources[key],
            "count": number_tasks[key]
        })
    return tasks


def get_unalloc_resource(master_state):
    """
    for a given mesos_state look into the agent to find the unallocated
    resource (cpus and memory) and return those values

    :param master_state: master-state from /master/state
    :type master_state: dict
    :return: a tuple of cpu and memory unallocated resources
    :rtype: tuple(float, float)

    """
    unalloc = []
    for agent in master_state['slaves']:
        unalloc.append((
            agent['resources']['cpus'] - agent['used_resources']['cpus'],
            agent['resources']['mem'] - agent['used_resources']['mem']
        ))
    return unalloc
