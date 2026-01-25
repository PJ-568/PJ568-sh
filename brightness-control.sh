#!/bin/bash

# 亮度控制脚本
# 用法: brightness-control.sh [亮度值] | [gui|--gui|-g]
# 亮度值范围: 0.1 到 1.9 (0.1 = 10%, 1.0 = 100%, 1.9 = 190%)
# 示例:
#   brightness-control.sh 0.5  # 设置亮度为 50%
#   brightness-control.sh 1.0  # 设置亮度为 100%
#   brightness-control.sh 1.5  # 设置亮度为 150%
#   brightness-control.sh gui  # 启动 GUI 界面

# 显示帮助信息
show_help() {
  echo "亮度控制脚本"
  echo "用法: $(basename "$0") [亮度值] | [gui|--gui|-g]"
  echo "亮度值范围: 0.1 到 1.9 (0.1 = 10%, 1.0 = 100%, 1.9 = 190%)"
  echo "示例:"
  echo "  $(basename "$0") 0.5  # 设置亮度为 50%"
  echo "  $(basename "$0") 1.0  # 设置亮度为 100%"
  echo "  $(basename "$0") 1.5  # 设置亮度为 150%"
  echo "  $(basename "$0") gui  # 启动 GUI 界面"
  echo "  $(basename "$0") help # 显示此帮助信息"
}

# 获取所有已连接的输出设备
get_connected_outputs() {
  # 使用 xrandr 获取已连接的输出，忽略可能的错误
  xrandr 2>/dev/null | grep " connected" | awk '{print $1}'
}

# 获取所有已连接设备的平均亮度值
get_average_brightness() {
  local outputs
  local output
  local brightness_sum=0
  local brightness_count=0
  local brightness_value
  local xrandr_output

  outputs=$(get_connected_outputs)
  if [ -z "$outputs" ]; then
    echo "1.0"
    return 0
  fi

  # 获取 xrandr --verbose 输出一次，避免重复调用
  xrandr_output=$(xrandr --verbose 2>/dev/null)

  for output in $outputs; do
    # 从 xrandr 输出中提取该显示器的亮度部分
    # 先找到显示器的连接部分，然后查找 Brightness: 或 Backlight: 行
    brightness_value=$(echo "$xrandr_output" | grep -A 20 "^$output connected" | grep -E "Brightness:|Backlight:" | head -1 | awk '{print $2}')
    
    # 如果没找到，尝试另一种模式：可能是 "Brightness" 没有冒号
    if [ -z "$brightness_value" ]; then
      brightness_value=$(echo "$xrandr_output" | grep -A 20 "^$output connected" | grep -i "brightness" | head -1 | awk '{print $NF}')
    fi

    # 验证亮度值是否为有效数字
    if [ -n "$brightness_value" ] && echo "$brightness_value" | grep -qE '^[0-9]+(\.[0-9]+)?$'; then
      brightness_sum=$(echo "scale=2; $brightness_sum + $brightness_value" | bc)
      brightness_count=$((brightness_count + 1))
    fi
  done

  if [ "$brightness_count" -eq 0 ]; then
    echo "1.0"
    return 0
  fi

  echo "scale=2; $brightness_sum / $brightness_count" | bc
}

# 设置亮度函数
set_brightness() {
  local brightness=$1
  local outputs
  local output

  echo "[Debug] brightness=$brightness"

  # 获取所有已连接的输出设备
  outputs=$(get_connected_outputs)
  if [ -z "$outputs" ]; then
    echo "错误: 未找到已连接的输出设备"
    exit 1
  fi

  # 根据亮度值选择设置方式
  if (( $(echo "$brightness < 1.0" | bc -l) )); then
    # 亮度小于 100%，使用 xrandr，xgamma 设为 1.0
    echo "亮度 < 100%，使用 xrandr 设置亮度"
    success=false
    for output in $outputs; do
      if xrandr --output "$output" --brightness "$brightness"; then
        echo "xrandr 设置成功 [$output]: $brightness"
        success=true
      else
        echo "警告: 输出设备 $output 亮度设置失败"
      fi
    done
    if [ "$success" = false ]; then
      echo "错误: 所有输出设备亮度设置失败"
      exit 1
    fi
    # 设置 xgamma 为 1.0
    xgamma -gamma 1.0 > /dev/null 2>&1
  elif (( $(echo "$brightness == 1.0" | bc -l) )); then
    # 亮度等于 100%，两者都设置为 1.0
    echo "亮度 = 100%，同时设置 xrandr 和 xgamma"
    success=false
    for output in $outputs; do
      if xrandr --output "$output" --brightness 1.0; then
        echo "xrandr 设置成功 [$output]: 1.0"
        success=true
      else
        echo "警告: 输出设备 $output 亮度设置失败"
      fi
    done
    if [ "$success" = false ]; then
      echo "错误: 所有输出设备亮度设置失败"
      exit 1
    fi
    if xgamma -gamma 1.0; then
      echo "xgamma 设置成功: 1.0"
    else
      echo "警告: xgamma 设置失败，但 xrandr 已设置"
    fi
  else
    # 亮度大于 100%，使用 xgamma，xrandr 设为 1.0
    echo "亮度 > 100%，使用 xgamma 设置亮度"
    if xgamma -gamma "$brightness"; then
      echo "xgamma 设置成功: $brightness"
      # 设置 xrandr 为 1.0（所有已连接输出）
      for output in $outputs; do
        xrandr --output "$output" --brightness 1.0 > /dev/null 2>&1
      done
    else
      echo "错误: xgamma 亮度设置失败"
      exit 1
    fi
  fi
}

# GUI 模式函数
show_gui() {
  # 获取当前平均亮度值（从所有已连接的输出设备）
  current_brightness=$(get_average_brightness)

  # 获取当前 gamma 值（计算三色平均值）
  current_gamma=$(xgamma 2>&1 | grep -Eo '[0-9]+(\.[0-9]+)?' | awk '{sum+=$1} END{if(NR==3) print sum/3; else print "1.0"}')
  if [ -z "$current_gamma" ] || [ "$current_gamma" = "0" ]; then
    current_gamma=1.0
  fi

  # 计算当前亮度与伽马之和减去一
  total_value=$(echo "scale=2; $current_brightness + $current_gamma - 1.0" | bc)

  # 转换为整数百分比值 (10-190)
  brightness_int=$(echo "$total_value * 100" | bc)

  # 使用 yad 创建亮度调节对话框 (使用整数范围 10-190)
  brightness_int=$(yad --title="亮度调节" --window-icon="preferences-system" \
    --scale --text="调整屏幕亮度:" --min-value=10 --max-value=190 --value="$brightness_int" \
    --step=5 --button="应用:2" --button="确定:0" --button="取消:1")

  # 检查用户点击的按钮
  button_return_code=$?

  # 如果点击取消，退出
  if [ $button_return_code -eq 1 ]; then
    echo "亮度调节已取消"
    exit 0
  fi

  # 如果点击应用，立即设置亮度但不退出
  if [ $button_return_code -eq 2 ]; then
    apply_brightness=true
  else
    apply_brightness=false
  fi

  # 验证 brightness_int 是否为有效数字
  if ! echo "$brightness_int" | grep -qE '^[0-9]+$'; then
    echo "错误: 获取的亮度值无效: $brightness_int"
    exit 1
  fi

  # 将整数转换为小数亮度值
  brightness=$(echo "scale=2; $brightness_int / 100" | bc)
  echo "[Debug] brightness_int=$brightness_int, brightness=$brightness"

  # 确保亮度值在有效范围内 (0.1-1.9)
  if (( $(echo "$brightness < 0.1" | bc -l) )); then
    brightness=0.1
  elif (( $(echo "$brightness > 1.9" | bc -l) )); then
    brightness=1.9
  fi

  # 设置亮度
  echo "正在设置屏幕亮度为 $brightness..."
  set_brightness "$brightness"

  # 如果点击的是应用按钮，重新显示对话框以便继续调整
  if [ "$apply_brightness" = true ]; then
    show_gui
  fi
}

# 检查参数数量
if [ $# -eq 0 ]; then
  echo "错误: 需要提供亮度值参数"
  show_help
  exit 1
fi

# 处理帮助请求
if [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  show_help
  exit 0
fi

# 处理 GUI 请求
if [ "$1" = "gui" ] || [ "$1" = "--gui" ] || [ "$1" = "-g" ]; then
  show_gui
  exit 0
fi

# 输入验证 - 检查是否为数字
if ! echo "$1" | grep -qE '^[0-9]+(\.[0-9]+)?$'; then
  echo "错误: 亮度值必须是数字"
  show_help
  exit 1
fi

# 输入验证 - 检查亮度值范围
brightness=$1
if (( $(echo "$brightness < 0.1" | bc -l) )) || (( $(echo "$brightness > 1.9" | bc -l) )); then
  echo "错误: 亮度值必须在 0.1 到 1.9 之间"
  show_help
  exit 1
fi

# 设置亮度
echo "正在设置屏幕亮度为 $brightness..."
set_brightness "$brightness"
