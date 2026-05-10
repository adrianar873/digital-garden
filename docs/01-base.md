# 01 — Base Setup: Disks, Docker & Backup

## Hardware

- Raspberry Pi 5 — 8GB RAM
- 64GB SD card (Raspberry Pi OS Lite 64-bit)
- 2x 1TB SSDs connected via USB

## Disk Layout

```
NAME        SIZE FSTYPE  MOUNTPOINT
sda       931.5G
└─sda1    931.5G ext4   /mnt/disk1    ← data
sdb       931.5G
└─sdb1    931.5G ext4   /mnt/disk2    ← backup
mmcblk0     59.5G
├─mmcblk0p1 512M vfat   /boot/firmware
└─mmcblk0p2  59G ext4   rootfs        ← OS on SD card
```

### Directory Structure

```bash
sudo mkdir -p /mnt/disk1/{immich,nextcloud,docker,media,downloads}
sudo mkdir -p /mnt/disk2/backups
```

```
/mnt/disk1/
├── immich/       # Photos & videos
├── nextcloud/    # File storage
├── docker/       # Bind mounts for configs & DBs
├── media/        # Movies / TV (future)
└── downloads/    # Torrents / usenet (future)

/mnt/disk2/
└── backups/      # Rsync mirror of /mnt/disk1
```

### Mount via fstab (with UUID)

```bash
# Get UUIDs
sudo blkid

# Add to /etc/fstab
UUID=xxxx-xxxx-xxxx /mnt/disk1 ext4 defaults,nofail 0 2
UUID=yyyy-yyyy-yyyy /mnt/disk2 ext4 defaults,nofail 0 2
```

## Docker Installation

```bash
# Prerequisites
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl

# Add Docker's official GPG key & repository
curl -fsSL https://get.docker.com | sudo sh

# Add user to docker group (avoids sudo)
sudo usermod -aG docker $USER

# Log out and back in, or run:
newgrp docker

# Verify
docker --version
docker compose version
```

## Backup Script

A daily rsync backs up `/mnt/disk1` to `/mnt/disk2`.

Full script: [`scripts/system/backup.sh`](../scripts/system/backup.sh)

```bash
# Make it executable
chmod +x ~/digital-garden/scripts/system/backup.sh

# Add cron job — runs daily at 3 AM
crontab -e
# Add this line:
0 3 * * * /home/adrian/digital-garden/scripts/system/backup.sh
```

## What's Next

- [02 — WireGuard VPN](02-vpn.md)
