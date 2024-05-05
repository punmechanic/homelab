output "gitea_client_secret" {
  value     = keycloak_openid_client.gitea.client_secret
  sensitive = true
}
