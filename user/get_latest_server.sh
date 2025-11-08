#!/bin/bash
LATEST_VER=$(curl -s https://api.github.com/repos/perfect-panel/ppanel-web/releases/latest | jq -r '.tag_name')
SERVER_URL="https://github.com/perfect-panel/ppanel-web/releases/download/${LATEST_VER}/ppanel-user-web.tar.gz"
mkdir -p /opt/ppanel
wget -O /opt/ppanel-user-web.tar.gz $SERVER_URL
tar -xvf /opt/ppanel-user-web.tar.gz -C /opt/ppanel/