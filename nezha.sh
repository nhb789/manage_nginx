#!/bin/bash

# 哪吒探针一键安装运行脚本
# 支持哪吒v0/v1，自动识别架构

# ========== 配置区 ==========
NEZHA_SERVER="你的哪吒域名/IP"
NEZHA_PORT="哪吒端口，v1留空"
NEZHA_KEY="你的哪吒密钥"
UUID="9afd1229-b893-40c1-84dd-51e7ce204913"
INSTALL_DIR="/opt/nezha"
# ============================

# 创建目录
mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR}

# 架构判断
ARCH=$(uname -m)
if [[ ${ARCH} == "aarch64" || ${ARCH} == "arm64" ]]; then
    OS_ARCH="arm64"
    DL_URL="https://arm64.ssss.nyc.mn"
else
    OS_ARCH="amd64"
    DL_URL="https://amd64.ssss.nyc.mn"
fi

# 下载对应版本
if [[ -z ${NEZHA_PORT} ]]; then
    # 哪吒v1
    wget -O nezha-agent ${DL_URL}/v1
else
    # 哪吒v0
    wget -O nezha-agent ${DL_URL}/agent
fi

# 授权
chmod +x nezha-agent

# 停止旧进程
pkill -f nezha-agent
sleep 1

# 运行
if [[ -z ${NEZHA_PORT} ]]; then
    # 哪吒v1 配置文件
    cat > config.yaml << EOF
client_secret: ${NEZHA_KEY}
debug: false
disable_auto_update: true
disable_command_execute: false
disable_force_update: true
disable_nat: false
disable_send_query: false
gpu: false
insecure_tls: true
ip_report_period: 1800
report_delay: 4
server: ${NEZHA_SERVER}
skip_connection_count: true
skip_procs_count: true
temperature: false
tls: false
use_gitee_to_upgrade: false
use_ipv6_country_code: false
uuid: ${UUID}
EOF

    # 判断TLS
    if [[ ${NEZHA_SERVER} == *":443" || ${NEZHA_SERVER} == *":8443" || ${NEZHA_SERVER} == *":2096" || ${NEZHA_SERVER} == *":2087" || ${NEZHA_SERVER} == *":2083" || ${NEZHA_SERVER} == *":2053" ]]; then
        sed -i 's/tls: false/tls: true/' config.yaml
    fi

    nohup ./nezha-agent -c config.yaml >/dev/null 2>&1 &
else
    # 哪吒v0
    NEZHA_TLS=""
    if [[ ${NEZHA_PORT} == "443" || ${NEZHA_PORT} == "8443" || ${NEZHA_PORT} == "2096" || ${NEZHA_PORT} == "2087" || ${NEZHA_PORT} == "2083" || ${NEZHA_PORT} == "2053" ]]; then
        NEZHA_TLS="--tls"
    fi
    nohup ./nezha-agent -s ${NEZHA_SERVER}:${NEZHA_PORT} -p ${NEZHA_KEY} ${NEZHA_TLS} --disable-auto-update --report-delay 4 --skip-conn --skip-procs >/dev/null 2>&1 &
fi

echo "哪吒探针已启动"
ps -ef | grep nezha-agent | grep -v grep

