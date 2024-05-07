ui            = true
disable_mlock = true
cluster_addr  = "https://127.0.0.1:8201"

storage "raft" {
  path = "/var/raft"
}

telemetry {
  statsd_address = "statsd:8125"
  disable_hostname = true
}
