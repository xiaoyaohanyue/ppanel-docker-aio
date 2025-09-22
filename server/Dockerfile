FROM alpine:latest AS builder

RUN apk update && apk add --no-cache curl jq bash && \
    mkdir -p /opt/ppanel

COPY ./ppanel.yaml /opt/ppanel.yaml
RUN wget https://github.com/perfect-panel/server/releases/download/v1.1.1/ppanel-server-linux-amd64.tar.gz -O /opt/ppanel-server.tar.gz && \
    tar -xvf /opt/ppanel-server.tar.gz -C /opt/ppanel/ && \
    rm -rf /opt/ppanel/LICENSE && \
    mv /opt/ppanel.yaml /opt/ppanel/etc/ppanel.yaml

FROM alpine:latest

COPY --from=builder /opt/ppanel /opt/ppanel
RUN apk update && \
    apk add --no-cache tzdata gcompat && \
    chmod +x /opt/ppanel/ppanel-server

CMD ["/opt/ppanel/ppanel-server","run","--config","/opt/ppanel/etc/ppanel.yaml"]
