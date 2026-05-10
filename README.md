<h1 align="center">🌱 Digital Garden</h1>
<p align="center">
  <b>Self-hosted homelab on Raspberry Pi 5</b><br>
  <i>A living journal — every service documented as it grows</i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Board-Raspberry_Pi_5-c51a4a?style=flat&logo=raspberrypi">
  <img src="https://img.shields.io/badge/RAM-8GB-00ff00?style=flat">
  <img src="https://img.shields.io/badge/Storage-2×1TB_SSD-0077b6?style=flat">
  <img src="https://img.shields.io/badge/OS-RPi_OS_Lite_64bit-0f766e?style=flat">
</p>

<p align="center">
  <img src="images/logo.png" width="300" style="border-radius: 60px;">
</p>

---

## 📋 Table of Contents

- [Hardware](#hardware)
- [Services](#services)
- [Repo Structure](#repo-structure)
- [Quick Start](#quick-start)
- [Roadmap](#roadmap)

---

## 🖥️ Hardware

| Component | Spec |
|---|---|
| **Board** | Raspberry Pi 5 |
| **RAM** | 8GB |
| **Boot** | 64GB SD card — Raspberry Pi OS Lite (64-bit) |
| **Storage 1** | 1TB SSD → `/mnt/disk1` (data) |
| **Storage 2** | 1TB SSD → `/mnt/disk2` (backup) |

## 🛠️ Services

| # | Service | Type | Status |
|---|---|---|---|
| 01 | [Base Setup](docs/01-base.md) | Disks · Docker · Backup | ✅ Done |
| 02 | [WireGuard VPN](docs/02-vpn.md) | Secure remote access | ✅ Done |
| 03 | [Immich](docs/03-immich.md) | Google Photos alternative | 📝 Planned |
| 04 | [Nextcloud](docs/04-nextcloud.md) | Files · Calendar · Contacts | 📝 Planned |

## 📂 Repo Structure

```
digital-garden/
├── README.md               ← you are here
├── docs/                   ← service documentation (English)
│   ├── 01-base.md          ← base setup & backup
│   └── 02-vpn.md           ← WireGuard VPN
├── scripts/                ← install & maintenance scripts
│   ├── system/
│   │   └── backup.sh       ← daily rsync backup
│   └── wireguard/
│       ├── setup.sh        ← one-command server setup
│       └── add-client.sh   ← add a new VPN client
├── docker/                 ← docker-compose files
└── images/                 ← screenshots & media
```

## 🚀 Quick Start

```bash
# Clone the repo on your Pi
git clone <repo-url> ~/digital-garden && cd ~/digital-garden

# Base setup (disks, Docker, backup)
sudo bash scripts/system/backup.sh

# WireGuard VPN
sudo bash scripts/wireguard/setup.sh
sudo bash scripts/wireguard/add-client.sh phone your-domain.duckdns.org:51820
```

## 🗺️ Roadmap

- [x] Base setup: disks, Docker, rsync backup
- [x] WireGuard VPN server + client management
- [ ] Immich — photo backup
- [ ] Nextcloud — file sync & productivity
- [ ] Nginx Proxy Manager — reverse proxy & SSL
- [ ] AdGuard Home — network-wide ad blocking
- [ ] Jellyfin — media server

---

<p align="center">
  <i>Last updated: 2026-05-10</i>
</p>
