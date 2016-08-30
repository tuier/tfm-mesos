#!/bin/bash -v

IPPRIVATE=$$(wget http://169.254.169.254/latest/meta-data/local-ipv4 -qO -)
ZONE=$(wget -qO - http://169.254.169.254/latest/meta-data/placement/availability-zone)

echo "${cluster_name}" | tee /etc/mesos-master/cluster >/dev/null

cat << EOF > /etc/telegraf/telegraf.d/global.conf
[global_tags]
  server = "$${IPPRIVATE}"
  role = "master"
EOF

systemctl restart mesos-master telegraf rsyslog
