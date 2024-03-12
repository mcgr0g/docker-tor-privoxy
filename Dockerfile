ARG img_ver
ARG build_date=$(date +%Y-%m-%d)
ARG golang_ver=latest
ARG alpine_ver=latest
ARG squid_ver
ARG tor_ver
ARG snowflake_ver=main

FROM golang:${golang_ver} as build-env-snowflake
ARG snowflake_ver

WORKDIR /builder
RUN git config --global advice.detachedHead false && \
    git clone --depth=1 -b ${snowflake_ver} https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/snowflake.git

WORKDIR /builder/snowflake/client
RUN go mod download
RUN CGO_ENABLED=0 go build -o client -ldflags '-extldflags "-static" -w -s'  .

# # # # # # # # # # # # # # # # # # # # # # # # # # # # 
FROM golang:${golang_ver} as build-env-webtunnel
WORKDIR /builder
RUN git config --global advice.detachedHead false && \
    git clone --depth=1 https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/webtunnel.git
WORKDIR /builder/webtunnel/main/client
RUN go mod download
RUN CGO_ENABLED=0 go build -o client -ldflags '-extldflags "-static" -w -s'  .

# # # # # # # # # # # # # # # # # # # # # # # # # # # # 
ARG UPGRADE=false

FROM alpine:${alpine_ver}
ARG img_ver
ARG build_date
LABEL org.opencontainers.image.authors="Ronnie McGrog" \
      org.opencontainers.image.url="https://github.com/mcgr0g/talpa-altaica/" \
      org.opencontainers.image.documentation="https://github.com/mcgr0g/talpa-altaica/blob/master/README.md" \
      org.opencontainers.image.source="https://github.com/mcgr0g/talpa-altaica/blob/master/Dockerfile" \
      org.opencontainers.image.title="talpa-altaica" \
      org.opencontainers.image.description="tor proxy" \
      org.opencontainers.image.version="${img_ver}" \
      org.opencontainers.image.created="${build_date}"


ARG squid_ver
ARG tor_ver

RUN apk --no-cache add curl \
        privoxy \
        squid=${squid_ver} \
        tor=${tor_ver} \
        ca-certificates && \
    ln -sf /dev/stdout /var/log/privoxy/logfile && \
    chown -R squid:squid /var/cache/squid && \
    chown -R squid:squid /var/log/squid

ARG RECONFIGURED=false
COPY setup /opt/

COPY --from=build-env-snowflake /builder/snowflake/client/client /opt/tor/snowflake
COPY --from=build-env-webtunnel /builder/webtunnel/main/client/client /opt/tor/webtunnel

EXPOSE 8888 9050 9051

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
            CMD curl -sx localhost:8888 'https://check.torproject.org/' | \
            grep -qm1 Congratulations

CMD ["/bin/sh", "/opt/start.sh"]
