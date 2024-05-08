# Vault

Vault contains all secrets that we use within our cluster and applications.

## Setup

Create a new file named `.env` in the Vault folder:

    cat <<CONFIG > .env
    PGHOST=postgres
    PGUSER=terraform
    PGPASSWORD=$(cat ../../../ring0/secrets/terraform_postgres_backend_password.txt)
    PGSSLMODE=disable
    PG_SCHEMA_NAME=vault
    VAULT_ADDR=http://vault:8200
    CONFIG

**Important**: Unlike other `.env` files in this project which are intended to
be used by `source`, this is used by `--env-file` in Docker, so make sure to
omit `export`.

Create a new network. This network is used for configuration with Vault by
internal services, such as initial configuration.

    docker network create vault -d overlay --attachable

Deploy the stack:

    docker stack up vault --compose-file stack.yaml

After deploying the stack, you will need to get the root token for Vault so that
Vault can be configured to issue tokens to OIDC clients. We also need to unseal
Vault.

First, initialize Vault:

    VAULT_CONTAINER_ID=$(docker ps --filter "label=com.docker.swarm.service.name=vault_vault" -q | head -n 1)
    docker exec -it -e VAULT_ADDR=http://127.0.0.1:8200 "$VAULT_CONTAINER_ID" vault operator init

Vault will output 5 unseal keys and a root token. The unseal keys should be
guarded and probably written down on paper and stored in a safe. Multiple times.
If you lose these unseal keys, there is **no going back without losing all of
your data**.

The root token will be used in the next step to apply the base configuration
that enables auth methods. **It must then be discarded**.

To apply the base Tofu, we run this manual task. Subsequent scripts will use
OIDC for this.

    VAULT_TOKEN={{root vault token from step vault init}}

    docker run \
        -e "VAULT_TOKEN=$VAULT_TOKEN" \
        --env-file .env \
        --network vault \
        --network global_terraform \
        --volume $(pwd)/tofu:/sources \
        registry.aredherring.tech/tofu-runner:latest
