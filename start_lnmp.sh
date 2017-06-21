#!/usr/bin/env bash

if [[ $1 == '' ]]
then
    echo '''
        请指定工作目录：
            ./start_lnmp.sh <work dir>
        例如：
            ./start_lnmp.sh `pwd` # 指定当前目录
    '''
    exit 1;
fi

export NGINX_PORT="8080"
export SWOOLE_HTTP_PORT="80"
export SWOOLE_TCP_PORT="9009"
export WEBSITE_DOMAIN="www.dev.com";
export ROOT_PATH=$1;
echo "工作目录：${ROOT_PATH}"

export LOCAL_HOST_IP="`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`"
echo "本机IP地址：${LOCAL_HOST_IP}"

echo
echo

# 项目配置初始化
echo "项目代码配置初始化..."
export PMA_PATH="${ROOT_PATH}/pma";

# true, false 定义
TRUE=1
FALSE=0

# 创建初始化目录
mkdir -p ${ROOT_PATH}/mysql/data ${ROOT_PATH}/log/nginx ${ROOT_PATH}/log/php
touch ${ROOT_PATH}/log/php/xdebug.log

# 获取待启动指定环境标识
if [[ $2 == '' ]]; then
    ARG="up"
else
    ARG=$2
fi

if [[ $3 == '' ]]; then
    IMAGE=""
else
    IMAGE=$3
fi

# 启动 docker 环境
docker-compose -f docker-compose.yml stop
docker-compose -f docker-compose.yml ${ARG} ${IMAGE}
