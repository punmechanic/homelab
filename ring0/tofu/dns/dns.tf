provider "gandi" {}

resource "gandi_livedns_record" "sso" {
  zone   = "aredherring.tech"
  name   = "sso"
  type   = "A"
  values = ["192.168.0.215"]
  ttl    = 36000
}

resource "gandi_livedns_record" "gitea" {
  zone   = "aredherring.tech"
  name   = "gitea"
  type   = "A"
  values = ["192.168.0.215"]
  ttl    = 36000
}

resource "gandi_livedns_record" "grafana" {
  zone   = "aredherring.tech"
  name   = "grafana"
  type   = "A"
  values = ["192.168.0.215"]
  ttl    = 36000
}
