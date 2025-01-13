FROM alpine:latest AS builder

RUN apk update && apk add --no-cache curl jq bash

COPY ./get_latest_server.sh /opt/get_latest_server.sh
COPY ./.env /opt/.env
RUN bash /opt/get_latest_server.sh && \
    rm -rf /opt/ppanel/ppanel-admin-web/apps/admin/.env && \
    mv /opt/.env /opt/ppanel/ppanel-admin-web/apps/admin/.env


FROM oven/bun:alpine

COPY --from=builder /opt/ppanel/ppanel-admin-web /opt/ppanel
RUN apk update && \
    apk add --no-cache tzdata

    WORKDIR /opt/ppanel

CMD ["bun","apps/admin/server.js"]
