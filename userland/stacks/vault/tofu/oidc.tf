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
  default_role       = "default"
  tune {
    listing_visibility = "unauth"
  }
}

resource "vault_jwt_auth_backend_role" "default" {
  backend    = vault_jwt_auth_backend.keycloak.path
  role_name  = "default"
  user_claim = "preferred_username"

  allowed_redirect_uris = [
    "https://vault.aredherring.tech/ui/vault/auth/sso/oidc/callback",
    "http://localhost:8250/oidc/callback"
  ]
}

# A better implementation would use groups, but doing that requires making a custom mapper, so this will do for now.
resource "vault_identity_entity" "dan" {
  name     = "dan"
  policies = [vault_policy.sudo.name]

}

resource "vault_identity_entity_alias" "dan" {
  mount_accessor = vault_jwt_auth_backend.keycloak.accessor
  name           = "dan"
  canonical_id   = vault_identity_entity.dan.id
}

data "vault_policy_document" "sudo" {
  rule {
    path         = "*"
    capabilities = ["create", "read", "update", "delete", "list", "sudo"]
  }
}

resource "vault_policy" "sudo" {
  name   = "sudo"
  policy = data.vault_policy_document.sudo.hcl
}
