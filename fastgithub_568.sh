#!/bin/bash

# 初始化路径常量
ROOT_DIR="${HOME}/.local/${USER}"
SCR_DIR="${ROOT_DIR}/scripts"
APP_DIR="${ROOT_DIR}/applications"
TMP_DIR="${ROOT_DIR}/tmp"
FG_DIR="${APP_DIR}/fastgithub"

if [ ! -d "${TMP_DIR}" ]; then
    mkdir -p "${TMP_DIR}"
fi

# 判断脚本是否被直接执行
if [ ! -f "${SCR_DIR}/fastgithub_568.sh" ]; then
    echo "正在安装脚本。"
    if [ ! -d "${SCR_DIR}" ]; then
        mkdir -p "${SCR_DIR}"
    fi

    wget -P "${TMP_DIR}" https://gitee.com/PJ-568/PJ568-sh/raw/main/fastgithub_568.sh || { echo "下载更新 失败，退出。"; exit 1; }
    mv -f "${TMP_DIR}/fastgithub_568.sh" "${SCR_DIR}/fastgithub_568.sh"

    echo "给予脚本可执行权限。"
    sudo chmod +x "${SCR_DIR}/fastgithub_568.sh"

    echo "脚本已安装。"
fi

echo "检查本目录是否在 PATH 中。"
if ! grep -q "${SCR_DIR}" <<< "$PATH"; then
    echo "请手动将脚本目录添加到 PATH 中。如运行以下命令："
    echo "echo \"export PATH=\$PATH:${SCR_DIR}\" >> ~/.bashrc"
    exit 0
fi

# 判断是否已安装 FastGithub
if [ ! -f "${FG_DIR}/fastgithub" ]; then
    echo "FastGithub 不存在，下载安装。"

    if [ ! -d "${APP_DIR}" ]; then
        mkdir -p "${APP_DIR}"
    fi

    wget -P "${TMP_DIR}" https://github.moeyy.xyz/https://github.com/WangGithubUser/FastGitHub/releases/download/v2.1.5/fastgithub_linux-x64.zip || { echo "下载 FastGithub 失败，退出。"; exit 1; }
    unzip "${TMP_DIR}/fastgithub_linux-x64.zip"
    rm "${TMP_DIR}/fastgithub_linux-x64.zip"

    mv -f "${TMP_DIR}/fastgithub_linux-x64" "${FG_DIR}"

    sudo chmod +x "${FG_DIR}/fastgithub"
fi

# 命令行参数解析
echo "正在启动 FastGithub 。"
for i in $@; do
    if [ "$i" == "start" ]; then
        sudo "${FG_DIR}/fastgithub" start || { echo "启动失败。"; exit 1; }
        echo "FastGithub 启动成功，默认代理地址：http://localhost:38457"
        git config --global http.https://github.com.proxy http://127.0.0.1:38457
        git config --global https.https://github.com.proxy http://127.0.0.1:38457
    elif [ "$i" == "stop" ]; then
        sudo "${FG_DIR}/fastgithub" stop || { echo "停止失败。"; exit 1; }
        echo "FastGithub 停止成功。"
        git config --global --unset http.proxy
        git config --global --unset https.proxy
    elif [ "$i" == "update" ]; then
        wget -P "${TMP_DIR}" https://gitee.com/PJ-568/PJ568-sh/raw/main/fastgithub_568.sh || { echo "下载更新 失败，退出。"; exit 1; }
        mv -f "${TMP_DIR}/fastgithub_568.sh" "${SCR_DIR}/fastgithub_568.sh"
        echo "更新成功，请重启脚本。"
    else
        echo "使用方法|Usage: fastgithub [start|stop|update]"
    fi
done
