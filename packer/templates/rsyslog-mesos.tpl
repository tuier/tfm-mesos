$EscapeControlCharactersOnReceive off
module(load="imudp")
module(load="imfile")

input(type="imudp" port="1095" ruleset="log-forwarder")
input(
    type="imfile"
    tag="syslog"
    statefile="/var/run/mesos_syslog.state"
    file="/var/log/syslog"
    ruleset="log-forwarder"
)

