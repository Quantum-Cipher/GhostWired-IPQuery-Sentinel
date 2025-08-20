#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${HERE}/.." && pwd)"

LOG_DIR="${ROOT}/logs"
CONF_DIR="${ROOT}/conf"
BYPASS_FILE="${CONF_DIR}/bypass.list"
ENV_FILE="${CONF_DIR}/guardian.env"
LOG_FILE="${LOG_DIR}/whisper_ipquery.log"

mkdir -p "${LOG_DIR}"

# load env if present
if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' "${ENV_FILE}" | xargs -I{} echo {})
fi

IPQUERY_BASE_URL="${IPQUERY_BASE_URL:-https://ipquery.io/api}"
IPQUERY_API_KEY="${IPQUERY_API_KEY:-}"
THROTTLE="${IPQUERY_THROTTLE:-0.5}"

usage() {
  cat <<USAGE
GhostWired Watchdog
Usage:
  $0 --ip 1.2.3.4 [--ip 5.6.7.8]
  $0 --file ./ips.txt
  $0 --stdin

Notes:
  - Config: ${ENV_FILE}
  - Bypass: ${BYPASS_FILE}
  - Log:    ${LOG_FILE}
USAGE
}

MODE=""
ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ip) shift; ARGS+=("$1"); shift || true;;
    --file) shift; FILE="$1"; MODE="file"; shift || true;;
    --stdin) MODE="stdin"; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1"; usage; exit 1;;
  esac
done

if [[ -z "${MODE}" && ${#ARGS[@]} -eq 0 ]]; then
  usage; exit 1
fi

PY="${ROOT}/bin/ipqwery_guardian.py"

if [[ "${MODE}" == "file" ]]; then
  # file mode: feed lines to guardian via stdin
  if [[ ! -f "${FILE}" ]]; then
    echo "No such file: ${FILE}" >&2; exit 1
  fi
  < "${FILE}" "${PY}" --stdin --log "${LOG_FILE}" --bypass "${BYPASS_FILE}" \
      --base-url "${IPQUERY_BASE_URL}" --api-key "${IPQUERY_API_KEY}" --sleep "${THROTTLE}"
elif [[ "${MODE}" == "stdin" ]]; then
  "${PY}" --stdin --log "${LOG_FILE}" --bypass "${BYPASS_FILE}" \
      --base-url "${IPQUERY_BASE_URL}" --api-key "${IPQUERY_API_KEY}" --sleep "${THROTTLE}"
else
  # list mode: pass as repeated --ip
  CMD=( "${PY}" --log "${LOG_FILE}" --bypass "${BYPASS_FILE}" \
        --base-url "${IPQUERY_BASE_URL}" --api-key "${IPQUERY_API_KEY}" --sleep "${THROTTLE}" )
  for ip in "${ARGS[@]}"; do
    CMD+=( --ip "${ip}" )
  done
  "${CMD[@]}"
fi
