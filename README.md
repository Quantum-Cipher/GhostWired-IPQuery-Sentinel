# 🛡️ GhostWired-IPQuery-Sentinel

**GhostWired-IPQuery-Sentinel** is Eternum’s **zero-trust security module** — a Watchdog Sentinel powered by [ipquery.io](https://ipquery.io).

It continuously monitors IP activity, enriches events with geolocation + risk intelligence, and seals immutable audit logs into **Whisper Trails**.  
This project demonstrates how Eternum integrates real-world IP intelligence into its quantum-aware defense lattice.

---

## 👁 Features
- ✅ **IP Intelligence** → enrich logs with IP, ISP, geo, and risk metadata from ipquery.io  
- ✅ **Immutable Whisper Logs** → append-only JSONL records in `/logs`  
- ✅ **Phantom Daemon Ready** → plug into honeypots + decoys  
- ✅ **Automation Friendly** → examples for cron/CI/CD  
- ✅ **GitHub Action Status Check** → ensures logging structure is always validated  

---

## 🚀 Quick Start

Clone and run the Sentinel:

```sh
git clone https://github.com/Quantum-Cipher/GhostWired-IPQuery-Sentinel.git
cd GhostWired-IPQuery-Sentinel

# Run against current IP
./bin/ghostwired_watchdog.sh

# Run against a specific IP
TARGET_IP=8.8.8.8 ./bin/ghostwired_watchdog.sh
