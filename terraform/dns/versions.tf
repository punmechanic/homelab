terraform {
  backend "pg" {}

  required_providers {
    gandi = {
      version = "2.3.0"
      source  = "go-gandi/gandi"
    }
  }
}
