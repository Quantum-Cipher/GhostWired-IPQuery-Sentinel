#!/usr/bin/env bash
# Example cron entry (edit with: crontab -e)
# Runs every 5 minutes, reading IPs from a feed file:
# */5 * * * * /bin/bash -lc 'cd "$HOME/GhostWired-IPQuery-Sentinel" && bin/ghostwired_watchdog.sh --file logs/incoming_ips.log >> logs/cron.out 2>&1'
