terraform {
  backend "pg" {
    schema_name = "keycloak"
  }

  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.4.0"
    }
  }
}
