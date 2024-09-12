#!/bin/sh

# 创建备份文件
if [ ! -f "/etc/hosts.bak" ]; then
    echo "备份 hosts 文件到 /etc/hosts.bak 中。"
    sudo cp /etc/hosts /etc/hosts.bak || { echo "备份 hosts 文件失败。"; exit 1; }
else
    echo "从 /etc/hosts.bak 恢复 hosts 文件。"
    # 使用临时文件来恢复
    TMPFILE=$(mktemp)
    sudo cat /etc/hosts.bak > "$TMPFILE" || { echo "恢复 hosts 文件失败。"; exit 2; }
    sudo mv "$TMPFILE" /etc/hosts || { echo "移动临时文件失败。"; exit 3; }
fi

echo "开始写入 Github hosts。"
TMPFILE=$(mktemp)
sudo curl https://hosts.gitcdn.top/hosts.txt >> "$TMPFILE" || { echo "写入 Github hosts 失败。"; exit 4; }
sudo sh -c "cat $TMPFILE >> /etc/hosts" || { echo "追加 Github hosts 到 /etc/hosts 失败。"; exit 5; }

echo "完毕，请重启网络配置。"
exit 0