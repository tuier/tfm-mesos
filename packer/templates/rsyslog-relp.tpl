module(load="omrelp")

template(name="empty" type="string" string="%rawmsg:::%")

ruleset(name="log-forwarder"){
    action(
        name="log-forwarder"
        type="omrelp"
        target="logs"
        port="1095"
        template="empty"
		queue.type="LinkedList"
		queue.spoolDirectory="/var/spool/rsyslog/relp"
		queue.filename="relp"
		queue.maxdiskspace="75161927680"
		queue.saveonshutdown="on"
		action.resumeRetryCount="-1"
		action.resumeInterval="5"
    )
}

