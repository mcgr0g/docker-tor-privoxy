ARG squid_ver=4.13-10
ARG privoxy_ver=3.0.32-2*
ARG geoipdb_ver=0.4.5.10-1*
ARG tor_ver=0.4.5.10-1*

FROM golang:1.18-bullseye

ARG squid_ver
ARG privoxy_ver
ARG geoipdb_ver
ARG tor_ver

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        squid=${squid_ver} \
        tor=${tor_ver} \
        tor-geoipdb=${geoipdb_ver} \
        privoxy=${privoxy_ver} \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    ln -sf /dev/stdout /var/log/privoxy/logfile

COPY setup /opt/

EXPOSE 8888 9050 9051

CMD ["/bin/sh", "/opt/start.sh"]
