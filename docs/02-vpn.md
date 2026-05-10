# 02 — WireGuard VPN

A lightweight, fast VPN for secure remote access to your homelab.

WireGuard is built into the Linux kernel since 5.6 — no extra kernel modules needed on RPiOS 64-bit.

## Scripts

| Script | Purpose |
|---|---|
| [`scripts/wireguard/setup.sh`](../scripts/wireguard/setup.sh) | Full server setup: install, keys, config, service |
| [`scripts/wireguard/add-client.sh`](../scripts/wireguard/add-client.sh) | Add a new client peer + generate config + QR code |

### Quick start (automated)

```bash
sudo ./scripts/wireguard/setup.sh
sudo ./scripts/wireguard/add-client.sh phone your-domain.duckdns.org:51820
```

## Manual setup (step by step)

### 1. Generate keys

```bash
cd /etc/wireguard
sudo mkdir -p /etc/wireguard
cd /etc/wireguard
wg genkey | sudo tee server.key | wg pubkey | sudo tee server.pub
sudo chmod 600 server.key
```

### 2. Create server config

```ini
sudo nano /etc/wireguard/wg0.conf
```

```
[Interface]
Address = 10.0.0.1/24
ListenPort = 51820
PrivateKey = <paste server.key content>
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o <WAN_IFACE> -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o <WAN_IFACE> -j MASQUERADE
```

### 3. Enable IP forwarding

```bash
echo 'net.ipv4.ip_forward=1' | sudo tee /etc/sysctl.d/99-wireguard.conf
sudo sysctl -p /etc/sysctl.d/99-wireguard.conf
```

### 4. Add a client peer

Generate a keypair for each client:

```bash
# On client device, or generate on server:
wg genkey | tee client1.key | wg pubkey > client1.pub
```

Append this to `/etc/wireguard/wg0.conf`:

```
[Peer]
# Client 1 — phone/laptop
PublicKey = <client1.pub>
AllowedIPs = 10.0.0.2/32
```

### 5. Start WireGuard

```bash
sudo systemctl enable --now wg-quick@wg0
sudo systemctl status wg-quick@wg0
```

## Client Config (example for phone/laptop)

```
[Interface]
Address = 10.0.0.2/32
PrivateKey = <client1.key>
DNS = 10.0.0.1

[Peer]
PublicKey = <server.pub>
Endpoint = <your-public-ip-or-domain>:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
```

## Port Forwarding

Forward UDP port **51820** on your router to the Pi's IP.

## Useful commands

```bash
sudo wg show                 # Show connection status
sudo systemctl restart wg-quick@wg0
sudo wg addconf wg0 <(wg-quick strip wg0)  # Reload config without restart
```
