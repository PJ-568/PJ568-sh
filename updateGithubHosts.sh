#!/bin/sh

if [ -f "/etc/hosts.bak" ]; then
    echo "备份 hosts 文件到 /etc/hosts.bak 中。"
    sudo cp /etc/hosts /etc/hosts.bak || { echo "移动 hosts 文件失败。"; exit 1; }
else
    echo "从 /etc/hosts.bak 恢复 hosts 文件中。"
    sudo cat /etc/hosts.bak > /etc/hosts || { echo "恢复 hosts 文件失败。"; exit 2; }
fi
echo "开始写入 Github hosts。"
sudo curl https://hosts.gitcdn.top/hosts.txt >> /etc/hosts || { echo "写入 Github hosts 失败。"; exit 3; }

echo "完毕，请重启网络配置。"
exit 0
