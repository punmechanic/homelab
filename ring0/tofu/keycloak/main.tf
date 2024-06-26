provider "keycloak" {}

resource "keycloak_realm" "realm" {
  realm = "homelab"
}

resource "keycloak_openid_client" "gitea" {
  realm_id            = keycloak_realm.realm.id
  client_id           = "gitea"
  name                = "gitea.aredherring.tech"
  access_type         = "CONFIDENTIAL"
  valid_redirect_uris = ["https://gitea.aredherring.tech/user/oauth2/keycloak/callback"]
  # PKCE is not supported by Gitea OIDC.
  # pkce_code_challenge_method = "S256"
  standard_flow_enabled = true
  consent_required      = true
}
