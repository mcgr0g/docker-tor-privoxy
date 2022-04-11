ARG squid_ver=5.4.1-r0
ARG tor_ver=0.4.6.10-r0
ARG snowflake_ver=v2.1.0

FROM golang:1.18 as build-env-snowflake
ARG snowflake_ver
LABEL img_filter="torproxy"

WORKDIR /builder
RUN git config --global advice.detachedHead false && \
    git clone --depth=1 -b ${snowflake_ver} https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake.git

WORKDIR /builder/snowflake/client
RUN go mod download
RUN CGO_ENABLED=0 go build -o client -ldflags '-extldflags "-static" -w -s'  .

FROM alpine:edge
ARG squid_ver
ARG tor_ver

ARG UPGRADE=false
RUN apk --no-cache add privoxy \
        squid=${squid_ver} \
        tor=${tor_ver} \
        ca-certificates && \
    ln -sf /dev/stdout /var/log/privoxy/logfile && \
    chown -R squid:squid /var/cache/squid && \
    chown -R squid:squid /var/log/squid

ARG RECONFIGURED=false
COPY setup /opt/

COPY --from=build-env-snowflake /builder/snowflake/client/client /opt/tor/client

EXPOSE 8888 9050 9051

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
            CMD curl -sx localhost:8888 'https://check.torproject.org/' | \
            grep -qm1 Congratulations

CMD ["/bin/sh", "/opt/start.sh"]
