#!/bin/bash

export HY2_PORT="" #端口
export HY2_PASSWORD="" #密码
export IP="" #服务器IP地址
WORKDIR="`pwd`" #此变量无需编辑

#生成自签SSL证书
generate_cert() {
echo "生成SSL证书中"
rm -rf ${WORKDIR}/private.key ${WORKDIR}/csr.pem ${WORKDIR}/cert.crt 
openssl genpkey -algorithm RSA -out ${WORKDIR}/private.key
openssl req -new -key ${WORKDIR}/private.key -out ${WORKDIR}/csr.pem -subj "/C=/ST=/L=/O=/OU=/CN=/emailAddress="
openssl req -x509 -days 3650 -key ${WORKDIR}/private.key -in ${WORKDIR}/csr.pem -out ${WORKDIR}/cert.crt
if [ $? == 0 ]; then
echo "完成"
else
echo "出现错误，请检查"
exit 1
fi
}

#生成sing-box配置
generate_config() {
echo "生成sing-box配置中，文件为${WORKDIR}/config.json"
sleep 1
rm -rf ${WORKDIR}/config.json
cat > ${WORKDIR}/config.json << EOF
{
  "log": {
    "disabled": false,
    "level": "warn",
    "timestamp": true
  },
  "inbounds": [{
      "type": "hysteria2",
      "sniff": true,
      "sniff_override_destination": true,
      "tag": "hy2",
      "listen": "::",
      "listen_port": "${HY2_PORT}",
      "up_mbps": 300,
      "down_mbps": 300,
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
sing-box check -c ${WORKDIR}/config.json
if [ $? == 0 ]; then
echo "完成"
else
echo "出现错误，请检查环境变量是否正确填写"
exit 1
fi
}

#打印hy2链接
print_list() {
echo "
----------------------------
hy2配置：
hysteria2://${HY2_PASSWORD}@${IP}:${HY2_PORT}/?insecure=1
----------------------------
"
}

main() {
cd ${WORKDIR}
generate_cert
[ ! -e ${WORKDIR}/config.json ] && generate_config
print_list
nohup sing-box run -c ${WORKDIR}/config.json &
}

main "$@"