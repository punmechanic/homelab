provider "gandi" {}

resource "gandi_livedns_record" "sso" {
  zone   = "aredherring.tech"
  name   = "sso"
  type   = "A"
  values = ["67.187.230.62"]
  ttl    = 36000
}

resource "gandi_livedns_record" "gitea" {
  zone   = "aredherring.tech"
  name   = "gitea"
  type   = "A"
  values = ["67.187.230.62"]
  ttl    = 36000
}
