#!/bin/bash -v

IPPRIVATE=$$(wget http://169.254.169.254/latest/meta-data/local-ipv4 -qO -)
ZONE=$(wget -qO - http://169.254.169.254/latest/meta-data/placement/availability-zone)

echo "zone:$${ZONE: -1}" | tee /etc/mesos-slave/attributes >/dev/null

cat << EOF > /etc/telegraf/telegraf.d/global.conf
[global_tags]
  server = "$${IPPRIVATE}"
  role = "agent"
EOF
rm /tmp/mesos -rf
systemctl restart mesos-* telegraf rsyslog
