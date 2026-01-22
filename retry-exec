#!/bin/bash

# retry-exec
# 用法: retry-exec <command> [args...]
# 如果命令执行失败（非零退出码），则重试直到成功。

set -u  # 未定义变量报错

show_usage() {
  echo "用法: $0 <command> [args...]"
  echo "重试执行命令直到成功（退出码为 0）。"
  echo "示例:"
  echo "  $0 curl -I https://example.com"
  echo "  $0 ping -c 1 8.8.8.8"
  echo "  $0 'some command with spaces'"
}

if [ $# -eq 0 ]; then
  show_usage
  exit 1
fi

# 记录重试次数
attempt=1

echo "开始重试执行命令: $*"
echo "按 Ctrl+C 中断。"

while true; do
  printf "尝试 #%d: \n" "$attempt"
  # 执行命令并捕获退出状态
  if "$@"; then
    echo "命令执行成功。"
    exit 0
  else
    ret=$?
    echo "命令失败，退出码: $ret"
    attempt=$((attempt + 1))
    # 添加短暂延迟以避免高频重试
    sleep 1
  fi
done
