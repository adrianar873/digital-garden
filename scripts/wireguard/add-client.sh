#!/bin/bash
# Add a new WireGuard client peer + generate config + QR
# Usage: sudo ./add-wireguard-client.sh <client-name> [endpoint]
# Example: sudo ./add-wireguard-client.sh phone exampledomain.duckdns.org:51820

set -e

if [ "$EUID" -ne 0 ]; then
    echo "Run with sudo: sudo $0 <client-name>"
    exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: sudo $0 <client-name>"
    echo "Example: sudo $0 phone"
    exit 1
fi

CLIENT=$1
ENDPOINT=${2:-"<PUBLIC-IP-OR-DDNS>:51820"}
SERVER_PUB=$(cat /etc/wireguard/server.pub 2>/dev/null || echo "")
if [ -z "$SERVER_PUB" ]; then
    echo "server.pub not found — is WireGuard installed?"
    exit 1
fi

# Detect last IP in use from wg0.conf
LAST_IP=$(grep AllowedIPs /etc/wireguard/wg0.conf | grep -o '10\.0\.0\.[0-9]*' | sort -t. -k4 -n | tail -1)
if [ -z "$LAST_IP" ]; then
    CLIENT_IP="10.0.0.2"
else
    LAST_OCTET=$(echo "$LAST_IP" | awk -F. '{print $4}')
    CLIENT_IP="10.0.0.$((LAST_OCTET + 1))"
fi

# Generate client keys
cd /etc/wireguard
wg genkey | tee "${CLIENT}.key" | wg pubkey > "${CLIENT}.pub"
chmod 600 "${CLIENT}.key"

CLIENT_PUB=$(cat "${CLIENT}.pub")
CLIENT_PRIV=$(cat "${CLIENT}.key")

# Add peer to server config
cat >> /etc/wireguard/wg0.conf << EOF

[Peer]
# $CLIENT
PublicKey = $CLIENT_PUB
AllowedIPs = ${CLIENT_IP}/32
EOF

# Restart WireGuard
systemctl restart wg-quick@wg0

# Generate client config
CONFIG="/tmp/wireguard-${CLIENT}.conf"
cat > "$CONFIG" << EOF
[Interface]
Address = ${CLIENT_IP}/32
PrivateKey = $CLIENT_PRIV
DNS = 10.0.0.1

[Peer]
PublicKey = $SERVER_PUB
Endpoint = $ENDPOINT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Try QR code (install if missing)
if ! command -v qrencode &>/dev/null; then
    echo "Installing qrencode..."
    apt install -y qrencode -qq
fi

echo ""
echo "========== QR CODE for $CLIENT =========="
cat "$CONFIG" | qrencode -t ansiutf8
echo "========================================="
echo ""
echo "Client:      $CLIENT"
echo "IP:          $CLIENT_IP"
echo "Config file: $CONFIG"
echo ""
echo "Endpoint set to: $ENDPOINT"
echo "Then transfer to device or scan QR above."
