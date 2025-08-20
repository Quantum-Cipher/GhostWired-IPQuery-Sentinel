#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="logs"
LOG_FILE="${LOG_DIR}/whisper_ipquery.log"
mkdir -p "$LOG_DIR"

# Simple arg parser: --ip <addr> (can be repeated)
IPS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ip)
      if [[ -n "${2-}" ]]; then
        IPS+=("$2"); shift 2
      else
        echo "Error: --ip requires a value" >&2; exit 1
      fi
      ;;
    -*|--*)
      echo "Unknown option: $1" >&2; exit 1
      ;;
    *)
      echo "Unexpected argument: $1" >&2; exit 1
      ;;
  esac
done

if [[ ${#IPS[@]} -eq 0 ]]; then
  echo "Usage: $0 --ip <addr> [--ip <addr> ...]" >&2
  exit 1
fi

timestamp() { date +"%Y-%m-%d %H:%M:%S%z"; }

log() {
  echo "[$(timestamp)] $*" | tee -a "$LOG_FILE"
}

query_ip() {
  local ip="$1"
  if command -v curl >/dev/null 2>&1; then
    # Lightweight IP info query; adjust as needed for your project
    local resp
    resp=$(curl -fsS "https://ipinfo.io/${ip}/json" || true)
    if [[ -n "$resp" ]]; then
      log "IP ${ip} info: ${resp}"
    else
      log "IP ${ip} query returned no data"
    fi
  else
    # Fallback: just record reachability via ping
    if ping -c1 -t2 "$ip" >/dev/null 2>&1; then
      log "IP ${ip} reachable"
    else
      log "IP ${ip} unreachable"
    fi
  fi
}

# Run queries
for ip in "${IPS[@]}"; do
  query_ip "$ip"
done

log "Watchdog run complete for ${#IPS[@]} IP(s)."
