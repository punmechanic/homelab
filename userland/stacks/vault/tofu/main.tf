provider "vault" {}

terraform {
  backend "pg" {}
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "4.2.0"
    }
  }
}

variable "sso_oidc_client_id" {
  type = string
}

variable "sso_oidc_client_secret" {
  type      = string
  sensitive = true
}
