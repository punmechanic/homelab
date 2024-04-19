terraform {
  required_providers {
    gandi = {
      version = "2.3.0"
      source  = "go-gandi/gandi"
    }
  }
}

provider "gandi" {}

resource "gandi_domain" "aredherring_tech" {
  name      = "aredherring.tech"
  autorenew = true
  owner {
    city            = "Dublin"
    country         = "IE"
    data_obfuscated = true
    email           = "aredherring2+gandi@gmail.com"
    extra_parameters = {
      "birth_city"       = ""
      "birth_country"    = ""
      "birth_date"       = ""
      "birth_department" = ""
    }
    family_name     = "Pantry"
    given_name      = "Dan"
    mail_obfuscated = true
    phone           = "+353.838838549"
    street_addr     = "Hanover Quarter"
    type            = "person"
    zip             = "D02 RC90"
  }

  billing {
    city            = "Dublin"
    country         = "IE"
    data_obfuscated = true
    email           = "aredherring2+gandi@gmail.com"
    extra_parameters = {
      "birth_city"       = ""
      "birth_country"    = ""
      "birth_date"       = ""
      "birth_department" = ""
    }
    family_name     = "Pantry"
    given_name      = "Dan"
    mail_obfuscated = true
    phone           = "+353.838838549"
    street_addr     = "Hanover Quarter"
    type            = "person"
    zip             = "D02 RC90"
  }
}

locals {
  # TODO: How frequently does this change?
  ip_address = "67.187.230.62"
}

resource "gandi_livedns_record" "whoami" {
  zone   = gandi_domain.aredherring_tech.name
  ttl    = 3600
  name   = "whoami"
  type   = "A"
  values = [local.ip_address]
}

resource "gandi_livedns_record" "traefik" {
  zone   = gandi_domain.aredherring_tech.name
  ttl    = 3600
  name   = "traefik"
  type   = "A"
  values = [local.ip_address]
}
