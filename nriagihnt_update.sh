#!/bin/bash

sleep 20

# 目录
ROOT_DIR="/home/nriagihnt/.local/PJ568"
SRC_DIR="${ROOT_DIR}/scripts"
APP_DIR="${ROOT_DIR}/applications"
TMP_DIR="${ROOT_DIR}/tmp"

if [ ! -d "$TMP_DIR" ]; then
    mkdir -p "$TMP_DIR"
fi

# nriagihnt_update.sh
wget -P "$TMP_DIR" https://gitee.com/PJ-568/PJ568-sh/raw/main/nriagihnt_update.sh
chmod +x "$TMP_DIR/nriagihnt_update.sh"
if [ ! -d "$SRC_DIR" ]; then
    mkdir -p "$SRC_DIR"
fi
mv -f "$TMP_DIR/nriagihnt_update.sh" "$SRC_DIR/nriagihnt_update.sh"

# lb-chat 客户端
mv /home/nriagihnt/.config/html-chat-gtk /home/nriagihnt/.config/LB-Chat
wget -P "$TMP_DIR" https://gitee.com/PJ-568/lb-chat/raw/main/client/client.sh
chmod +x "$TMP_DIR/client.sh"
if [ ! -d "$APP_DIR/html-chat" ]; then
    mkdir -p "$APP_DIR/html-chat"
fi
mv -f "$TMP_DIR/client.sh" "$APP_DIR/html-chat/html-chat-gtk"

# Search.html 文件
wget -P "$TMP_DIR" https://gitee.com/PJ-568/Search.html/raw/main/index.html
wget -P "$TMP_DIR" https://gitee.com/PJ-568/Search.html/raw/main/favicon.svg
if [ ! -d "$APP_DIR/Search.html" ]; then
    mkdir -p "$APP_DIR/Search.html"
fi
mv -f "$TMP_DIR/index.html" "$APP_DIR/Search.html/index.html"
mv -f "$TMP_DIR/favicon.svg" "$APP_DIR/Search.html/favicon.svg"
