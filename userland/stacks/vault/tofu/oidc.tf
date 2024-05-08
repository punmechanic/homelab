data "terraform_remote_state" "sso" {
  backend = "pg"
  config = {
    schema_name = "keycloak"
  }
}

resource "vault_jwt_auth_backend" "keycloak" {
  path               = "sso"
  type               = "oidc"
  bound_issuer       = "https://sso.aredherring.tech/realms/homelab"
  oidc_discovery_url = "https://sso.aredherring.tech/realms/homelab"
  oidc_client_id     = data.terraform_remote_state.sso.outputs.vault_client_id
  oidc_client_secret = data.terraform_remote_state.sso.outputs.vault_client_secret
  tune {
    listing_visibility = "unauth"
  }
}
