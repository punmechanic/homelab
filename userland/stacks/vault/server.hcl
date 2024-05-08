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

listener "tcp" {
  address = "0.0.0.0:8200"
  # TLS is disabled because we terminate TLS at the load balancer.
  tls_disable = true
}
