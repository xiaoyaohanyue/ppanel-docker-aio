FROM alpine:latest AS builder

RUN apk update && apk add --no-cache curl jq bash && \
    mkdir -p /opt/ppanel

COPY ./ppanel.yaml /opt/ppanel.yaml
COPY ./get_latest_server.sh /opt/get_latest_server.sh

RUN bash /opt/get_latest_server.sh && \
    rm -rf /opt/ppanel/LICENSE && \
    mv /opt/ppanel.yaml /opt/ppanel/etc/ppanel.yaml

FROM alpine:latest

COPY --from=builder /opt/ppanel /opt/ppanel
RUN apk update && \
    apk add --no-cache tzdata gcompat && \
    chmod +x /opt/ppanel/ppanel-server

CMD ["/opt/ppanel/ppanel-server","run","--config","/opt/ppanel/etc/ppanel.yaml"]
