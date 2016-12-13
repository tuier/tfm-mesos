#!/bin/bash -v

echo "${cluster_name}" | tee /etc/mesos-master/cluster >/dev/null

systemctl daemon-reload
systemctl restart mesos-master
