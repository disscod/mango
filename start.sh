#!/bin/bash

echo "=== 開始啟動 ==="

# 啟動 Flask（背景）
python app.py &

# 安裝 unzip（保險）
apt update -y && apt install -y unzip wget > /dev/null 2>&1

# 用鏡像下載（關鍵！）
wget -q -O xray.zip https://ghproxy.com/https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip

if [ ! -f xray.zip ]; then
  echo "❌ Xray 下載失敗"
  sleep 9999
fi

unzip -o xray.zip > /dev/null 2>&1
chmod +x xray

# cloudflared（鏡像）
wget -q -O cloudflared https://ghproxy.com/https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64
chmod +x cloudflared

# UUID
UUID=$(cat /proc/sys/kernel/random/uuid)
echo "UUID: $UUID"

# config
cat > config.json <<EOF
{
  "inbounds": [{
    "port": 8080,
    "protocol": "vless",
    "settings": {
      "clients": [{"id": "$UUID"}]
    },
    "streamSettings": {
      "network": "ws"
    }
  }],
  "outbounds": [{"protocol": "freedom"}]
}
EOF

# 啟動 Xray
./xray run -c config.json &
sleep 2

# 檢查 Xray
ps aux | grep xray

echo "=== 啟動 Argo ==="

# 前台（關鍵）
./cloudflared tunnel --url http://localhost:8080
