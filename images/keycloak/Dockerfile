# This custom container definition mostly exists to let Keycloak read the pg password from a file.
FROM keycloak/keycloak:24.0.3
COPY --chown=keycloak run.sh /opt/keycloak/bin/run-with-secrets.sh
RUN chmod +x /opt/keycloak/bin/run-with-secrets.sh
ENTRYPOINT ["/opt/keycloak/bin/run-with-secrets.sh"]
