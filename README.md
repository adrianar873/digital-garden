![Logo](images/Logo.jpeg)

# Digital Garden — Raspberry Pi 5 (8GB)

A living journal of my self-hosted homelab setup. Every service is documented as I build it.

## Hardware

| Component | Spec |
|---|---|
| Board | Raspberry Pi 5 |
| RAM | 8GB |
| Boot | 64GB SD card (Raspberry Pi OS Lite 64-bit) |
| Storage 1 | 1TB SSD → `/mnt/disk1` (data) |
| Storage 2 | 1TB SSD → `/mnt/disk2` (backup) |

## Services

| # | Service | Status |
|---|---|---|
| 01 | [Base Setup: Disks, Docker & Backup](docs/01-base.md) | ✅ Done |
| 02 | [WireGuard VPN](docs/02-vpn.md) | 📝 Planned |
| 03 | [Immich](docs/03-immich.md) | 📝 Planned |
| 04 | [Nextcloud](docs/04-nextcloud.md) | 📝 Planned |

## Repo Structure

```
digital-garden/
├── README.md          ← you are here
├── docs/              ← service docs (in English)
├── scripts/           ← install & maintenance scripts
├── docker/            ← docker-compose files
└── images/            ← screenshots & media
```

_Last updated: 2026-05-10_
