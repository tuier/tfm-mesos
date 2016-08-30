[[inputs.zookeeper]]
  servers = ["localhost:2181"]
  fielddrop =["followers","*sync*","version","watch_count","packet*"]
