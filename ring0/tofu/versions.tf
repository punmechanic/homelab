terraform {
  backend "pg" {}
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.4.0"
    }
    gandi = {
      version = "2.3.0"
      source  = "go-gandi/gandi"
    }
  }
}
