# Changelog

Breaking changes are listed first in each entry.
## 1.53.0-2 (2026-11-16)

- README: Deploy on Railway button linking to the published template `inngest-1`. No change to the app or its configuration.


## 1.53.0-1 (2026-11-16)

- First release: Inngest v1.53.0 (`inngest/inngest:v1.53.0@sha256:cae99a7f08bf0c5c4b94d311c51f8bb90c18ecf5d24595933243e97a22d35bb4`) with Railway Postgres and Redis.
- Caddy 2.11.9 login (basic auth) in front of the dashboard and GraphQL API, which have no login in Inngest. SDK routes pass through and are checked by Inngest's event and signing keys. `/debug` is blocked.
