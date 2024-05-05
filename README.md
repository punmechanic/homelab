# Initial Setup

Follow these steps in order to deploy from scratch.

This uses _Docker Swarm_. Create a Swarm before executing any of these
instructions.

    docker swarm init

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

    docker network create \
        --driver overlay \
        --scope swarm \
        --attachable \
        --subnet 10.1.0.0/16 \
        traefik_services

A few services use an internal network named Openbao to enable them to
communicate through the Docker networking stack rather than going to the
internal network to reach Openbao.

    docker network create \
        --driver overlay \
        --scope swarm \
        --attachable \
        --subnet 10.0.5.0/24 \
        openbao

These networks have their own _subnets_. Containers connected to the networks
will be assigned an IP address from that subnet while on that network, and
traffic coming from them will be from an IP in those subnets. This allows us to
create rules that restrict access to services to our internal network.

- Openbao can only be accessed by internal services from 10.0.5.0/24 (253 usable
  addresses).

- Traefik will always communicate with its containers over 10.1.0.0/16 (65k
  usable addresses).

## Secrets

Generate new secrets:

    ./generate-secret.sh > secrets/keycloak_admin_password.txt
    ./generate-secret.sh > secrets/keycloak_pg_password.txt
    ./generate-secret.sh > secrets/terraform_postgres_backend_password.txt
    ./generate-secret.sh > secrets/gitea_postgres_password.txt
    mkdir -p secrets/gitea
    touch secrets/gitea/ci_runner_token.txt

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

Visit https://gitea.aredherring.tech and follow the installation Wizard. The
default settings will be correct, however, you must set up an administrator
account.

- Scroll to Optional Settings
- Click Administrator Account Settings
- Fill out as you prefer, but save the username and password in your password
  manager. You cannot name the account `admin`.
- You will now be logged in as the administrator account.

Now, we will add Keycloak as an identity provider.

- Click the avatar in the top right, then click Site Administration.
- Click Identity & Access, and then click Authentication Sources.

Enter the form as follows:

- Authentication Type: OAuth2
- Authentication Name: keycloak
- OAuth2 Provider: OpenID Connect
- Client ID: gitea
- Client Secret: `cd terraform/keycloak && tofu output -raw gitea_client_secret`
- OpenID Connect Auto Discovery URL: https://sso.aredherring.tech/realms/homelab

You should log in with your Keycloak account, which was created when Keycloak
was set up. You may need to log into Keycloak using the administrator account to
set up a password as there is no mailer set up yet.

Sometimes Gitea can be get stuck in a redirect loop after installation is done.
This can be resolved doing a hard-refresh.

#### CI

To set up CI, we need to add runners. Runners are created when the stack is
deployed, but the stack must be re-deployed to update the registration token on
them.

Log into the administration panel on Gitea.

- Click Actions.
- Click Runners.
- Click Create new Runner.
- Copy the Registration Token and add it to `secrets/gitea/ci_runner_token.txt`.
- Open `gitea.yaml`, and increment the number on `gitea_password.v1`.
- Redeploy the stack: `docker stack up --compose-file gitea.yaml gitea`

#### Pushing and pulling

This Gitea instance is not currently configured to use SSH passthrough, so you
can only push or pull using HTTPS.

You should configure your git locally to store credentials safely so you don't
have to repeatedly enter your username and password:

    git config --global credential.helper \
        /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret

You may need to install libsecret for this. Git 2.34.1 comes with the source
code for it but it must be compiled first:

    cd /usr/share/doc/git/contrib/credential/libsecret
    sudo make

## Openbao
