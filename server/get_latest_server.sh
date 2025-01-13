#!/bin/bash
LATEST_VER=$(curl -s https://api.github.com/repos/perfect-panel/ppanel/releases/latest | jq -r '.tag_name')
SERVER_URL="https://github.com/perfect-panel/ppanel/releases/download/${LATEST_VER}/ppanel-server-${LATEST_VER}-linux-amd64.tar.gz"
mkdir -p /opt/ppanel
wget -O /opt/ppanel-server.tar.gz $SERVER_URL
tar -xvf /opt/ppanel-server.tar.gz -C /opt/ppanel/