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

resource "gandi_livedns_record" "aredherring_tech" {
  zone = gandi_domain.aredherring_tech.name
  ttl  = 3600
  name = "sso"
  type = "A"
  # TODO: How frequently does this change?
  values = ["67.187.230.62"]
}
