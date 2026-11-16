# Caddy only supplies its static binary: it puts a login in front of the
# Inngest dashboard, which has no authentication of its own.
FROM caddy:2.11.9@sha256:4e2425f6009577e7c651010f16679c28f7d12df3e7b1914f941a7a3370746b3c AS caddy

FROM inngest/inngest:v1.53.0@sha256:cae99a7f08bf0c5c4b94d311c51f8bb90c18ecf5d24595933243e97a22d35bb4

COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY Caddyfile /etc/caddy/Caddyfile
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh && mkdir -p /data

ENV PORT=8080 \
    INNGEST_PORT=8288 \
    DASHBOARD_USERNAME=admin

EXPOSE 8080 8288 8289
ENTRYPOINT ["/usr/local/bin/start.sh"]
