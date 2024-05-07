# Vault

Vault contains all secrets that we use within our cluster and applications.

## Setup

Create a new file named `.env` in the Vault folder with contents similar to the
following:

    export PGUSER=terraform
    export PGPASSWORD=$(cat ../../../ring0/secrets/terraform_postgres_backend_password.txt)
    export PGSSLMODE=disable
    export PG_SCHEMA_NAME=vault
    export TF_VAR_sso_oidc_client_id=$(tofu -chdir="../../../ring0/tofu/keycloak" output -raw gitea_client_id)
    export TF_VAR_sso_oidc_client_secret=$(tofu -chdir="../../../ring0/tofu/keycloak" output -raw gitea_client_secret)
    export VAULT_ADDR=https://vault.aredherring.tech

Deploy the stack:

    docker stack up vault --compose-file stack.yaml

Wait a bit for Traefik to pick up the service, then apply the Tofu

    tofu init && tofu apply
