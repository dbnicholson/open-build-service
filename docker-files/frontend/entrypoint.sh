#!/bin/bash

set -e

# Read secrets from Vault if possible.
if [ -n "$VAULT_ADDR" ] && [ -n "$VAULT_SECRET_PATH" ]; then
    if [ -z "$VAULT_TOKEN" ]; then
        VAULT_LOGIN_ARGS="${VAULT_LOGIN_ARGS:--method=aws}"
        # shellcheck disable=SC2086
        VAULT_TOKEN=$(vault login -token-only $VAULT_LOGIN_ARGS </dev/null)
        export VAULT_TOKEN
    fi

    DATABASE_NAME=$(vault kv get -field=name "${VAULT_SECRET_PATH}/database/api")
    DATABASE_USER=$(vault kv get -field=user "${VAULT_SECRET_PATH}/database/api")
    DATABASE_PASSWORD=$(vault kv get -field=password "${VAULT_SECRET_PATH}/database/api")
    export DATABASE_NAME DATABASE_USER DATABASE_PASSWORD

    SECRET_KEY=$(vault kv get -field=key "${VAULT_SECRET_PATH}/api-secret")
    export SECRET_KEY

    unset VAULT_TOKEN
fi

envsubst < /obs/config/database.yml.in > /obs/config/database.yml
envsubst < /obs/config/options.yml.in > /obs/config/options.yml
envsubst < /obs/config/thinking_sphinx.yml.in > /obs/config/thinking_sphinx.yml

if [ -n "$SECRET_KEY" ]; then
    echo -n "$SECRET_KEY" > /obs/config/secret.key
fi

exec bundle exec "$@"
