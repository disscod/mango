#!/bin/bash

# 下載 Xray
wget -O xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
unzip xray.zip
chmod +x xray

# 下載 cloudflared
wget -O cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared

# UUID（自訂）
UUID=$(cat /proc/sys/kernel/random/uuid)

# 建立 config
cat > config.json <<EOF
{
  "inbounds": [{
    "port": 8080,
    "protocol": "vless",
    "settings": {
      "clients": [{
        "id": "$UUID"
      }]
    },
    "streamSettings": {
      "network": "ws",
      "security": "none"
    }
  }],
  "outbounds": [{
    "protocol": "freedom"
  }]
}
EOF

echo "你的UUID: $UUID"

# 啟動 Xray
./xray run -c config.json &

# 啟動 Argo（臨時域名）
./cloudflared tunnel --url http://localhost:8080 &

# 防止退出（關鍵）
while true; do sleep 1000; done
