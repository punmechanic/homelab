terraform {
  backend "pg" {
    schema_name = "dns"
  }

  required_providers {
    gandi = {
      version = "2.3.0"
      source  = "go-gandi/gandi"
    }
  }
}
