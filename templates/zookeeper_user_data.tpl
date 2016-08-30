#!/bin/bash -v
systemctl enable exhibitor
systemctl stop exhibitor

IPPRIVATE=$$(wget http://169.254.169.254/latest/meta-data/local-ipv4 -qO -)

cat << EOF > /etc/telegraf/telegraf.d/global.conf
[global_tags]
  server = "$${IPPRIVATE}"
  role = "zookeeper"
EOF

cat  <<EOF > /etc/default/exhibitor
EX_CONF_TYPE=s3
EX_CONFIGURATION=--s3config ${fqdn}:exhibitor/zk.conf --s3backup true --s3region ${region} --defaultconfig /opt/exhibitor/default.conf
EOF

systemctl daemon-reload
systemctl restart telegraf exhibitor
