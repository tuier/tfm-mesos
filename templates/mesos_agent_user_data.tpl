#!/bin/bash -v

ZONE=$(wget -qO - http://169.254.169.254/latest/meta-data/placement/availability-zone)

echo "zone:$${ZONE: -1}" | tee /etc/mesos-slave/attributes >/dev/null

systemctl stop mesos-*

rm -rf /tmp/mesos /var/lib/mesos/meta/slaves/latest
systemctl daemon-reload
systemctl restart mesos-*
