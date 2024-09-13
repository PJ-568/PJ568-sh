#! /bin/bash
# 该脚本用于处理 makepkg 安装软件时，由 github 下载缓慢甚至无法下载的问题
# 检测域名是不是 github，如果是，则替换为镜像网站，依旧使用 curl 下载
# 如果不是 github 则采用 curl 进行下载
# 实验用链接：
# https://githubfast.com/PJ-568/PJ568-sh/archive/refs/heads/main.zip
# https://github.com/PJ-568/PJ568-sh/archive/refs/heads/main.zip

domin=`echo $2 | cut -f3 -d'/'`;
others=`echo $2 | cut -f4- -d'/'`;
case "$domin" in 
    "github.com")
    url="https://githubfast.com/"$others;
    echo "download from github mirror $url";
    /usr/bin/curl -qgb "" -fLC - --retry 3 --retry-delay 3 -o $1 $url;
    ;;
    *)
    url=$2;
    /usr/bin/curl -qgb "" -fLC - --retry 3 --retry-delay 3 -o $1 $url;
    # /usr/bin/axel -n 15 -a -o $1 $url;
    ;;
esac