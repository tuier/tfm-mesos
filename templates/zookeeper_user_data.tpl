#!/bin/bash -v
systemctl enable exhibitor
systemctl stop exhibitor

cat  <<EOF > /etc/default/exhibitor
EX_CONF_TYPE=s3
EX_CONFIGURATION=--s3config ${fqdn}:exhibitor/zk.conf --s3backup true --s3region ${region} --defaultconfig /opt/exhibitor/default.conf
EOF

systemctl daemon-reload
systemctl restart exhibitor
