#!/bin/sh
set -e

[ -n "$VAULT_ADDR" ] || eval 'echo "missing VAULT_ADDR" 1>&2; exit 1'
[ -n "$VAULT_APP_ROLE" ] || eval 'echo "missing VAULT_APP_ROLE" 1>&2; exit 1'

TOKEN_DEST_PATH=${TOKEN_DEST_PATH:-"/var/run/secrets/vaultproject.io/.vault-token"}
mkdir -p ${TOKEN_DEST_PATH%/*}

ACCESSOR_DEST_PATH=${ACCESSOR_DEST_PATH:-"/var/run/secrets/vaultproject.io/.vault-accessor"}
mkdir -p ${ACCESSOR_DEST_PATH%/*}

SERVICE_ACCOUNT_PATH=${SERVICE_ACCOUNT_PATH:-"/var/run/secrets/kubernetes.io/serviceaccount/token"}
[ -e "$SERVICE_ACCOUNT_PATH" ] || eval 'echo "missing file \"$SERVICE_ACCOUNT_PATH\"" 1>&2; exit 1'

SERVICE_ACCOUNT_TOKEN=`cat ${SERVICE_ACCOUNT_PATH}`

response=`curl -sS --request POST --header "Content-type: application/json" --data '{"jwt": "'"$SERVICE_ACCOUNT_TOKEN"'", "role": "'"$VAULT_APP_ROLE"'"}' $VAULT_ADDR/v1/auth/kubernetes/login`

echo $response | jq -j '.auth.client_token' > $TOKEN_DEST_PATH
echo $response | jq -j '.auth.accessor' > $ACCESSOR_DEST_PATH

exec "$@"
