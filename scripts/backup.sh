#!/bin/bash
# Daily backup: /mnt/disk1 → /mnt/disk2/backups
# Runs via cron at 3 AM

SRC="/mnt/disk1/"
DST="/mnt/disk2/backups/"
LOG="/var/log/backup-disk.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

echo "[$TIMESTAMP] Starting backup..." >> "$LOG"

rsync -av --delete "$SRC" "$DST" >> "$LOG" 2>&1

if [ $? -eq 0 ]; then
    echo "[$TIMESTAMP] Backup completed successfully" >> "$LOG"
else
    echo "[$TIMESTAMP] Backup FAILED" >> "$LOG"
fi
echo "---------------------------" >> "$LOG"
