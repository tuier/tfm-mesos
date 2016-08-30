module(load="imudp")

input(
    type="imfile"
    file="/var/log/zookeeper/*.log"
    tag="zookeeper"
    statefile="/var/run/syslog.state"
    ruleset="log-forwarder"
)
input(
    type="imfile"
    file="/var/log/syslog"
    tag="syslog"
    statefile="/var/run/syslog.state"
    ruleset="log-forwarder"
)
