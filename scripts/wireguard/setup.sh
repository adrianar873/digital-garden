#!/bin/bash
# WireGuard VPN server setup for Raspberry Pi OS Lite
# Run with sudo

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
FAIL=0

echo -e "${YELLOW}[Check] Verifying dependencies...${NC}"

# --- Check kernel module ---
if modinfo wireguard &>/dev/null; then
    echo -e "${GREEN}  ✓ wireguard kernel module available${NC}"
else
    echo -e "${RED}  ✗ wireguard kernel module not found${NC}"
    FAIL=1
fi

# --- Check commands ---
for cmd in iptables wg ip; do
    if command -v $cmd &>/dev/null; then
        echo -e "${GREEN}  ✓ $cmd found${NC}"
    else
        echo -e "${RED}  ✗ $cmd not found (need: apt install iptables wireguard-tools)${NC}"
        FAIL=1
    fi
done

# --- Detect WAN interface ---
WAN_IFACE=$(ip -4 route show default | awk '{print $5}' | head -1)
if [ -n "$WAN_IFACE" ]; then
    echo -e "${GREEN}  ✓ WAN interface detected: $WAN_IFACE${NC}"
else
    echo -e "${RED}  ✗ No WAN interface found (is your Pi online?)${NC}"
    FAIL=1
fi

# --- Ensure running as root ---
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}  ✗ Run with sudo: sudo $0${NC}"
    FAIL=1
fi

if [ "$FAIL" -eq 1 ]; then
    echo -e "${RED}Fix the errors above and re-run.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[1/6] Installing wireguard-tools...${NC}"
apt install -y wireguard-tools

echo -e "${YELLOW}[2/6] Generating server keys...${NC}"
mkdir -p /etc/wireguard
cd /etc/wireguard
wg genkey | tee server.key | wg pubkey > server.pub
chmod 600 server.key

SERVER_PRIV=$(cat server.key)
SERVER_PUB=$(cat server.pub)

echo -e "${YELLOW}[3/6] Creating server config...${NC}"
tee /etc/wireguard/wg0.conf > /dev/null <<EOF
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = $SERVER_PRIV
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $WAN_IFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $WAN_IFACE -j MASQUERADE
EOF

echo -e "${YELLOW}[4/6] Enabling IP forwarding...${NC}"
echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-wireguard.conf
sysctl -p /etc/sysctl.d/99-wireguard.conf

echo -e "${YELLOW}[5/6] Starting WireGuard...${NC}"
systemctl enable --now wg-quick@wg0

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  WireGuard server is running!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Server public key: $SERVER_PUB"
echo "Listen port: 51820/udp"
echo "WAN interface: $WAN_IFACE"
echo ""
echo "To add a client:"
echo "  1. Generate client keys on your device"
echo "  2. Add to /etc/wireguard/wg0.conf:"
echo "     [Peer]"
echo "     PublicKey = <client pub>"
echo "     AllowedIPs = 10.0.0.2/32"
echo "  3. Restart: sudo systemctl restart wg-quick@wg0"
echo ""
echo "Don't forget to forward UDP 51820 on your router!"
