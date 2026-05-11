#!/usr/bin/env sh
set -eu

STACK_NAME="${STACK_NAME:-swarm-monitoring}"
STACK_FILE="${STACK_FILE:-docker-stack.yml}"
ENV_FILE="${1:-${POSTGRES_MONITORING_ENV_FILE:-./.env}}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Env file not found: $ENV_FILE" >&2
  echo "Create it from .env.example or pass path as the first argument." >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
. "$ENV_FILE"
set +a

: "${POSTGRES_EXPORTER_DATA_SOURCE_URI:?POSTGRES_EXPORTER_DATA_SOURCE_URI is required}"
: "${POSTGRES_EXPORTER_DATA_SOURCE_USER:?POSTGRES_EXPORTER_DATA_SOURCE_USER is required}"
: "${POSTGRES_EXPORTER_DATA_SOURCE_PASS:?POSTGRES_EXPORTER_DATA_SOURCE_PASS is required}"

docker stack deploy -c "$STACK_FILE" "$STACK_NAME"
docker service update --force "${STACK_NAME}_postgres_exporter"
