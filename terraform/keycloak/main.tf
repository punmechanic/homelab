provider "keycloak" {}

resource "keycloak_realm" "realm" {
  realm = "homelab"
}
