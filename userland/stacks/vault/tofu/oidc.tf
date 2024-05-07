resource "vault_jwt_auth_backend" "keycloak" {
  path               = "sso"
  type               = "oidc"
  bound_issuer       = "https://sso.aredherring.tech/realms/homelab"
  oidc_discovery_url = "https://sso.aredherring.tech/realms/homelab"
  oidc_client_id     = var.sso_oidc_client_id
  oidc_client_secret = var.sso_oidc_client_secret
  tune {
    listing_visibility = "unauth"
  }
}
