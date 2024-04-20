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
  ip_address = "192.168.0.215"
  entries    = []
}

resource "gandi_livedns_record" "entries" {
  for_each = toset(local.entries)
  zone     = gandi_domain.aredherring_tech.name
  ttl      = 3600
  name     = each.value
  type     = "A"
  values   = [local.ip_address]
}
