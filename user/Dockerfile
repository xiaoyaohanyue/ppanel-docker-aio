FROM alpine:latest AS builder

RUN apk update && apk add --no-cache curl jq bash

COPY ./get_latest_server.sh /opt/get_latest_server.sh
COPY ./.env /opt/.env
RUN bash /opt/get_latest_server.sh && \
    rm -rf /opt/ppanel/ppanel-user-web/apps/user/.env && \
    mv /opt/.env /opt/ppanel/ppanel-user-web/apps/user/.env


FROM oven/bun:alpine

COPY --from=builder /opt/ppanel/ppanel-user-web /opt/ppanel
RUN apk update && \
    apk add --no-cache tzdata

    WORKDIR /opt/ppanel

CMD ["bun","apps/user/server.js"]
