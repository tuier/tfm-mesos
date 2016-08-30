#!/bin/env python
# -*- coding: utf-8 -*-
"""
This script is use to auto scale up or down an ASG

"""
from __future__ import print_function

import sys
import logging
import json
import boto3
import botocore

logging.basicConfig(stream=sys.stderr, level=logging.INFO)


def lambda_handler(event, dummy_contest):
    """
        main function who is the entry point to the lambda function
        message from sns must contain:
        asg_name: name of the ASG you want to scale
        scale_num: number of node you want to scale (negatif or positif)
        min_node: number of node you want to keep at all time
    """
    sns_message = json.loads(event['Records'][0]['Sns']['Message'])
    logging.warning(sns_message)
    if 'asg_name' in sns_message and 'scale_num' in sns_message:
        scale(
            sns_message['asg_name'],
            int(sns_message['scale_num']),
            int(sns_message['min_node'])
        )
        logging.warning("scale done")
    else:
        logging.warning("Received: %s ", json.dumps(event, ident=1))


def scale(asg_name, scale_num, min_node):
    """
    change the desired capacity with the amount change in arguement

    :param asg_name: name of the ASG we want to scale
    :type asg_name: string

    :param scale: number of instance to add to the desirer instance
        (can be negatif)
    :type scale: int
    """
    if scale != 0:
        logging.warning("needed to scale %s by %d", asg_name, scale_num)
        boto_scale = boto3.client('autoscaling')
        asg = boto_scale.describe_auto_scaling_groups(
            AutoScalingGroupNames=[asg_name],
            MaxRecords=1
        )
        current_cap = int(asg['AutoScalingGroups'][0]['DesiredCapacity'])
        new_cap = max(current_cap + scale_num, min_node)
        logging.warning(
            "scaling to new cap %d, preview cap %d",
            new_cap,
            current_cap
        )
        try:
            boto_scale.set_desired_capacity(
                AutoScalingGroupName=asg_name,
                DesiredCapacity=new_cap,
                HonorCooldown=True
            )
        except botocore.exceptions.ClientError as cerr:
            logging.warning(cerr)
