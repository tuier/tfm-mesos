[[inputs.udp_listener]]
  service_address = ":5141"
  allowed_pending_messages = 10000
  data_format = "influx"

[[outputs.tcp_forwarder]]
  servers = ["stat:5141"]
  data_format ="influx"

