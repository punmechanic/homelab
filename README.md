# Initial Setup

Follow these steps in order to deploy from scratch

## DNS

### External DNS

We will first deploy our external DNS. This requires Postgres to be configured
so that we can save Tofu state. To start, create the following secret:

    ./generate_secret.sh > secrets/terraform_postgres_backend_password.txt

Then, deploy the `iac` (infrastructure as code) stack:

    docker stack up --compose-file iac.yaml iac

Generate a personal access token from https://gandi.net which has permissions to
manage DNS records, and store it in `secrets/gandi_api_key.txt.`

Create a new file in `terraform/dns` named `.env`. Fill it with the following
values:

    export PGUSER=terraform
    export PGPASSWORD=$(cat ../../secrets/terraform_postgres_backend_password.txt)
    export PGSSLMODE=disable
    export PG_SCHEMA_NAME=dns
    export GANDI_PERSONAL_ACCESS_TOKEN=$(cat ../secrets/gandi_api_key.txt)

Run `tofu apply`.

    cd terraform/dns
    source .env && tofu apply

### Internal DNS

DNS records are configured to point to `192.168.0.215` on external DNS on
aredherring.tech, but we have also configured our internal DNS at http://pi.hole
to point sso and gitea to the appropriate domains. Make sure to check
http://pi.hole if making changes to the IP address of the host machine.

## Network setup

The following network must be created for Traefik to be able to reach all
services. It must be created externally to Docker to ensure all services can
"see" it.

    docker network create --driver overlay --scope=swarm --attachable traefik_services

## Secrets

Generate new secrets:

    ./generate-secret.sh > secrets/keycloak_admin_password.txt
    ./generate-secret.sh > secrets/keycloak_pg_password.txt
    ./generate-secret.sh > secrets/terraform_postgres_backend_password.txt
    ./generate-secret.sh > secrets/gitea_postgres_password.txt

## Traefik

**If you anticipate the deployment will be unstable**, you must modify
`traefik.yaml` and uncomment the following line:

    # caServer: "https://acme-staging-v02.api.letsencrypt.org/directory"

If you do not do this, you will almost certainly hit a rate limit on the
official LetsEncrypt servers and be unable to issue certificates for a week.

You'll still be able to access services by clicking through SSL errors if you
use the staging CA server.

After confirming everything is fine, deploy the Traefik stack:

    docker stack up --compose-file traefik.yaml traefik

## Internal services

The rest of the services can be deployed in any order.

### Keycloak

A custom image is used for Keycloak because the original one is not
well-optimized for receiving secrets from Docker. Build that image first.

    docker build --tag registry.aredherring.tech/keycloak:latest -f images/keycloak/Dockerfile images/keycloak

Deploy the stack:

    docker stack up --compose-file keycloak.yaml keycloak

- Visit `https://sso.aredherring.tech` and log into Keycloak using the
  credentials `admin` and the password in `secrets/keycloak_admin_password.txt`
- Create a new Client in the `master` realm. Name it `terraform` - set the
  client ID to `terraform` as well. Tick "Client authentication", and untick all
  Authentication flow boxes except for "Service account roles", which should be
  ticked.
- Assign the new client the `create-realm` and `admin` Service account roles.
- Copy the client secret from the Credentials panel. Create a new `.env` file at
  `terraform/keycloak/.env` with the following values, replacing the client
  secret as appropriate.

```
export PGUSER=terraform
export PGPASSWORD=$(cat ../../secrets/terraform_postgres_backend_password.txt)
export PGSSLMODE=disable
export KEYCLOAK_CLIENT_ID=terraform
export PG_SCHEMA_NAME=keycloak
# This is pasted directly here because it is created by Keycloak rather than being managed by us.
export KEYCLOAK_CLIENT_SECRET="{{CLIENT SECRET GOES HERE}}"
export KEYCLOAK_URL=https://sso.aredherring.tech
```

Then, apply the tofu files:

    cd terraform/keycloak
    source .env && tofu apply

### Gitea

Deploy the stack:

    docker stack up --compose-file gitea.yaml gitea
