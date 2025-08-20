#!/bin/sh
set -eu
BASE="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
exec "$BASE/bin/ipqwery_guardian.py" "${1-}"
