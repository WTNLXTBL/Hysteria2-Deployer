#!/bin/bash
#以下三行是需要填写的变量
HY2_PORT=''
HY2_PASSWORD=''
IP=''
#此变量无需编辑
WORKDIR="${HOME}/singbox-start"

generate_config() {
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

export_list

[ ! -e ${WORKDIR}/config.json ] && generate_config

nohup sing-box run -c ${WORKDIR}/config.json &
