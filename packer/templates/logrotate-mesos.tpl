# exclude anyfile with only one number at the end, .1 (first rotation) this 
# will not work if the pid of mesos will be lower than 10

/var/log/mesos/*.log.*-*.*[0-9][0-9] {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    copytruncate
}
