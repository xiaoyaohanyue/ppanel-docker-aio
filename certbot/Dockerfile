# 使用 Certbot 官方镜像
FROM certbot/certbot:latest

RUN pip install certbot-dns-cloudflare  && \
pip install cloudflare==2.3.1

COPY cloudflare.ini /secrets/cloudflare.ini

ARG API_DOMAIN
ARG ADMIN_DOMAIN
ARG USER_DOMAIN
ARG EMAIL

# 设置环境变量（可选）
ENV API_DOMAIN=${API_DOMAIN}
ENV ADMIN_DOMAIN=${ADMIN_DOMAIN}
ENV USER_DOMAIN=${USER_DOMAIN}
ENV EMAIL=${EMAIL}

# 执行 Certbot 生成证书
RUN chmod 600 /secrets/cloudflare.ini && \
    eval "certbot certonly --dns-cloudflare \
    --dns-cloudflare-credentials /secrets/cloudflare.ini \
    --dns-cloudflare-propagation-seconds 20 \
    -d ${API_DOMAIN} \
    --email ${EMAIL} \
    --non-interactive --agree-tos --no-eff-email"
RUN eval "certbot certonly --dns-cloudflare \
    --dns-cloudflare-credentials /secrets/cloudflare.ini \
    --dns-cloudflare-propagation-seconds 20 \
    -d ${ADMIN_DOMAIN} \
    --email ${EMAIL} \
    --non-interactive --agree-tos --no-eff-email" 
RUN eval "certbot certonly --dns-cloudflare \
    --dns-cloudflare-credentials /secrets/cloudflare.ini \
    --dns-cloudflare-propagation-seconds 20 \
    -d ${USER_DOMAIN} \
    --email ${EMAIL} \
    --non-interactive --agree-tos --no-eff-email"
