#!/bin/sh
# Run the guardian for current IP and a known target, then exit.
set -eu
BASE="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
"$BASE/bin/ghostwired_watchdog.sh"
TARGET_IP=8.8.8.8 "$BASE/bin/ghostwired_watchdog.sh"
