#!/bin/bash
#以下三行是需要填写的变量
HY2_PORT=''
HY2_PASSWORD=''
IP=''
#此变量无需编辑
WORKDIR="${HOME}/singbox-start"

generate_cert() {
echo "生成SSL证书中，一路回车即可"
sleep 1
rm -rf ${WORKDIR}/private.key ${WORKDIR}/csr.pem ${WORKDIR}/cert.crt
openssl genpkey -algorithm RSA -out ${WORKDIR}/private.key
openssl req -new -key ${WORKDIR}/private.key -out ${WORKDIR}/csr.pem
openssl req -x509 -days 365 -key ${WORKDIR}/private.key -in ${WORKDIR}/csr.pem -out ${WORKDIR}/cert.crt
if [ $? == 0 ]; then
echo "完成"
else
echo "出现错误，请检查"
exit 1
fi
}

generate_config() {
echo "生成sing-box配置中，文件为${WORKDIR}/config.json"
sleep 1
rm -rf ${WORKDIR}/config.json
cat > ${WORKDIR}/config.json << EOF
{
  "log": {
    "disabled": false,
    "level": "info",
    "timestamp": true
  },
  "inbounds": [{
      "type": "hysteria2",
      "sniff": true,
      "sniff_override_destination": true,
      "tag": "hy2-sb",
      "listen": "::",
      "listen_port": ${HY2_PORT},
      "up_mbps": 900,
      "down_mbps": 360,
      "users": [{
        "password": "${HY2_PASSWORD}"
      }],
      "ignore_client_bandwidth": false,
      "tls": {
        "enabled": true,
        "alpn": [
          "h3"
        ],
        "certificate_path": "${WORKDIR}/cert.crt",
        "key_path": "${WORKDIR}/private.key"
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct",
      "domain_strategy": "ipv4_only"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ],
  "route": {
    "rules": [
      {
        "outbound": "direct",
        "network": "udp,tcp"
      }
    ]
  }
}
EOF
if [ $? == 0 ]; then
echo "完成"
else
echo "出现错误，请检查环境变量是否正确填写"
exit 1
fi
}

export_list() {
        rm -rf ${WORKDIR}/list
        cat > ${WORKDIR}/list << EOF
----------------------------
hy2配置：
hysteria2://${HY2_PASSWORD}@${IP}:${HY2_PORT}/?insecure=1
----------------------------
EOF
}

main() {
generate_cert
[ ! -e ${WORKDIR}/config.json ] && generate_config
export_list && cat ${WORKDIR}/list
nohup sing-box run -c ${WORKDIR}/config.json &
}

main "$@"