#!/bin/bash
# Starts Inngest and the Caddy login proxy in one container.
# Public traffic: Caddy on $PORT. Private network: Inngest on $INNGEST_PORT
# (8288) and the Connect gateway on 8289.
set -euo pipefail

fail() { echo "start.sh: $*" >&2; exit 1; }

export PORT="${PORT:-8080}"
export INNGEST_PORT="${INNGEST_PORT:-8288}"
export DASHBOARD_USERNAME="${DASHBOARD_USERNAME:-admin}"
# [::] listens on IPv4 and IPv6, so Railway's private network (IPv6) reaches it.
export INNGEST_HOST="${INNGEST_HOST:-[::]}"

[ -n "${INNGEST_EVENT_KEY:-}" ] || fail "INNGEST_EVENT_KEY is required"
[ -n "${INNGEST_SIGNING_KEY:-}" ] || fail "INNGEST_SIGNING_KEY is required (hex string, even length)"
[ -n "${DASHBOARD_PASSWORD:-}" ] || fail "DASHBOARD_PASSWORD is required"
[ "${#DASHBOARD_PASSWORD}" -ge 12 ] || fail "DASHBOARD_PASSWORD must be at least 12 characters"
[ "$PORT" != "$INNGEST_PORT" ] || fail "PORT and INNGEST_PORT must differ"

# Empty values mean "not set": SQLite on the /data volume and Inngest's
# built-in Redis, instead of failing on an empty URI.
[ -n "${INNGEST_POSTGRES_URI:-}" ] || unset INNGEST_POSTGRES_URI
[ -n "${INNGEST_REDIS_URI:-}" ] || unset INNGEST_REDIS_URI
if [ -z "${INNGEST_POSTGRES_URI:-}" ]; then
  export INNGEST_SQLITE_DIR="${INNGEST_SQLITE_DIR:-/data}"
  mkdir -p "$INNGEST_SQLITE_DIR"
fi

DASHBOARD_PASSWORD_HASH="$(printf '%s\n' "$DASHBOARD_PASSWORD" | caddy hash-password)"
export DASHBOARD_PASSWORD_HASH
unset DASHBOARD_PASSWORD

inngest start &
inngest_pid=$!
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
caddy_pid=$!

stop() { kill -TERM "$inngest_pid" "$caddy_pid" 2>/dev/null || true; }
trap stop TERM INT

# Exit as soon as either process stops, so Railway restarts the container.
set +e
wait -n "$inngest_pid" "$caddy_pid"
status=$?
stop
wait "$inngest_pid" "$caddy_pid" 2>/dev/null
exit "$status"
