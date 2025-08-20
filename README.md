# 🛡️ GhostWired: IPQuery Sentinel

This module scans, guards, and logs IP-based intelligence across the GhostWired ecosystem. Authored and cryptographically signed by **Quantum-Cipher**, it forms part of the wider Eternum security matrix.

## 🔍 Components
- `ghostwired_watchdog.sh`: Watches for suspicious IP activity
- `ipqwery_guardian.py`: Fetches IP metadata and flags anomalies
- `watchdog_cron.sh`: Schedule for continuous scanning

## 🔐 Verified by:
- GPG: `45BA2344CCAD2EB9`
- Author: `Quantum-Cipher <cipherpunk@eternum369.com>`

## 🔁 Ritual Sigil
See `SIGILTRUST.md` for the ceremonial trust log

---

## 🧭 Heads-Up (for non-mythic minds)

- **Quick run (dry-run):**
  ```bash
  bin/ghostwired_watchdog.sh --ip 1.1.1.1

---

## 🧭 Heads-Up (for non-mythic minds)

- Quick dry-run:
  ```bash
  bin/ghostwired_watchdog.sh --ip 1.1.1.1

---

## 🧭 Heads-Up (for non-mythic minds)

- Quick dry-run:
  bin/ghostwired_watchdog.sh --ip 1.1.1.1

- Live lookups:
  # in conf/guardian.env
  # IPQUERY_BASE_URL=https://api.ipquery.io/{ip}
  # IPQUERY_API_KEY=            # (optional for public endpoints)

- Logs:
  tail -n 20 logs/whisper_ipquery.log
