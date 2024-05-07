output "gitea_client_id" {
  value = keycloak_openid_client.gitea.client_id
}

output "gitea_client_secret" {
  value     = keycloak_openid_client.gitea.client_secret
  sensitive = true
}

output "vault_client_id" {
  value = keycloak_openid_client.vault.client_id
}

output "vault_client_secret" {
  value     = keycloak_openid_client.vault.client_secret
  sensitive = true
}
