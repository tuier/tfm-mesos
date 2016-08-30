[[inputs.cpu]]
  percpu = false
  totalcpu = true
  fieldpass = ["*usage*"]

[[inputs.disk]]
  [inputs.disk.tagpass ]
    fstype = ["rootfs"]

[[inputs.diskio]]
  [inputs.diskio.tagpass ]
    fstype = ["rootfs"]

[[inputs.mem]]

[[inputs.system]]
  fielddrop = ["*uptime_format"]
