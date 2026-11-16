[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/inngest-1?utm_medium=integration&utm_source=button&utm_campaign=inngest)

# Inngest on Railway

A Railway template for self-hosted [Inngest](https://www.inngest.com), the durable workflow and background job engine. Your apps send events to it, and Inngest runs their functions step by step, with retries, queues, crons and flow control. This repo is the source every deployed Inngest service builds from.

**Version:** Inngest v1.53.0 (`inngest/inngest:v1.53.0@sha256:cae99a7f08bf0c5c4b94d311c51f8bb90c18ecf5d24595933243e97a22d35bb4`), with Caddy 2.11.9 as a login proxy.

## What the template deploys

| Service | Source | Role |
|---|---|---|
| `Inngest` | this repo (`Dockerfile`) | Event API, queue, executor, dashboard. Public on port 8080 (Caddy), private on 8288 (Inngest) and 8289 (Connect gateway) |
| `Postgres` | Railway Postgres | Apps, functions, events and run history |
| `Redis` | Railway Redis | Queue and run state |

Inngest's self-hosted dashboard and GraphQL API have no login of their own. This template puts a Caddy login (HTTP basic auth) in front of them. The routes the Inngest SDKs call (`/e/*`, `/fn/register`, `/v0/connect`, `/v1/*`, `/v2/*`, `/api/v2/*`, `/v0/runs/*`, `/health`) pass straight through, because Inngest checks the event key or signing key on them itself. `/debug` (the Go profiler) is blocked.

## Variables (Inngest service)

| Variable | Default | Notes |
|---|---|---|
| `INNGEST_EVENT_KEY` | generated | Key apps use to send events |
| `INNGEST_SIGNING_KEY` | generated, 64 hex chars | Key apps and Inngest use to sign requests. Must be hex with an even length |
| `DASHBOARD_USERNAME` | `admin` | Dashboard login user |
| `DASHBOARD_PASSWORD` | generated | Dashboard login password (at least 12 characters) |
| `INNGEST_POSTGRES_URI` | `${{Postgres.DATABASE_URL}}` | Leave empty to use SQLite in `/data` (then mount a volume at `/data`) |
| `INNGEST_REDIS_URI` | `${{Redis.REDIS_URL}}` | Leave empty to use Inngest's built-in Redis (single node only) |
| `PORT` | `8080` | Public port (Caddy) |

Any other `inngest start` flag can be set as `INNGEST_<FLAG>`, for example `INNGEST_SDK_URL` or `INNGEST_POLL_INTERVAL` ([docs](https://www.inngest.com/docs/self-hosting)).

## Connecting your app

On your app's Railway service, set:

```
INNGEST_DEV=0
INNGEST_BASE_URL=http://${{Inngest.RAILWAY_PRIVATE_DOMAIN}}:8288
INNGEST_EVENT_KEY=${{Inngest.INNGEST_EVENT_KEY}}
INNGEST_SIGNING_KEY=${{Inngest.INNGEST_SIGNING_KEY}}
```

Then sync the app once: `curl -X PUT https://YOUR-APP-DOMAIN/api/inngest`. To sync automatically, set `INNGEST_SDK_URL=http://${{YOUR-APP.RAILWAY_PRIVATE_DOMAIN}}:YOUR-APP-PORT/api/inngest` on the Inngest service. Workers using Inngest Connect reach the gateway at `${{Inngest.RAILWAY_PRIVATE_DOMAIN}}:8289`.

## Updates

Every Inngest service deployed from this template builds from this repo's `main` branch. When we bump the pinned image here, Railway shows deployers an "update available" notice, and they choose when to apply it. Read [CHANGELOG.md](CHANGELOG.md) first: breaking changes are listed at the top of each entry.

## Licence

This wrapper repo: MIT. Inngest itself is under the Server Side Public License (SSPL) with a delayed Apache 2.0 release (see [Inngest's licence](https://github.com/inngest/inngest/blob/main/LICENSE.md)). Caddy is Apache 2.0.
