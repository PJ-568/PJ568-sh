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
wget -P "$TMP_DIR" https://gitee.com/PJ-568/PJ568-sh/raw/main/nriagihnt_update.sh || { echo "下载更新脚本失败，退出。"; exit 1; }
chmod +x "$TMP_DIR/nriagihnt_update.sh"
if [ ! -d "$SRC_DIR" ]; then
    mkdir -p "$SRC_DIR"
fi
mv -f "$TMP_DIR/nriagihnt_update.sh" "$SRC_DIR/nriagihnt_update.sh"

# lb-chat 客户端
wget -P "$TMP_DIR" https://gitee.com/PJ-568/lb-chat/raw/main/client/client.sh || { echo "下载 lb-chat 客户端失败，退出。"; exit 1; }
chmod +x "$TMP_DIR/client.sh"
if [ ! -d "$APP_DIR/html-chat" ]; then
    mkdir -p "$APP_DIR/html-chat"
fi
mv -f "$TMP_DIR/client.sh" "$APP_DIR/html-chat/html-chat-gtk"

# Search.html 文件
wget -P "$TMP_DIR" https://gitee.com/PJ-568/Search.html/raw/main/index.html || { echo "下载 Search.html 文件失败，退出。"; exit 1; }
wget -P "$TMP_DIR" https://gitee.com/PJ-568/Search.html/raw/main/favicon.svg || { echo "下载 Search.html 文件失败，退出。"; exit 1; }
if [ ! -d "$APP_DIR/Search.html" ]; then
    mkdir -p "$APP_DIR/Search.html"
fi
mv -f "$TMP_DIR/index.html" "$APP_DIR/Search.html/index.html"
mv -f "$TMP_DIR/favicon.svg" "$APP_DIR/Search.html/favicon.svg"
