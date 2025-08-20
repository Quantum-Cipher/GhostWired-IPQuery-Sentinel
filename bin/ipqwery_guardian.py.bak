#!/usr/bin/env python3
import argparse, json, os, sys, time
from ipaddress import ip_address, ip_network
from urllib.parse import urlencode, urljoin
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

def load_bypass(path):
    nets, singles = [], set()
    if not os.path.exists(path): return nets, singles
    with open(path, 'r', encoding='utf-8') as f:
        for line in f:
            s = line.strip()
            if not s or s.startswith('#'): continue
            try:
                if '/' in s:
                    nets.append(ip_network(s, strict=False))
                else:
                    singles.add(s)
            except Exception:
                # ignore bad lines, keep going
                continue
    return nets, singles

def is_bypassed(ip, nets, singles):
    if ip in singles: return True
    ipobj = ip_address(ip)
    # auto-skip common benign ranges
    if any([ipobj.is_private, ipobj.is_loopback, ipobj.is_link_local,
            ipobj.is_multicast, ipobj.is_reserved, ipobj.is_unspecified]):
        return True
    for n in nets:
        if ipobj in n: return True
    return False

def build_url(base, ip, api_key):
    # supports a templated base (contains "{ip}") or will append /ip
    if '{ip}' in base:
        u = base.replace('{ip}', ip)
        sep = '&' if ('?' in u) else '?'
        return f"{u}{sep}{urlencode({'api_key': api_key, 'key': api_key, 'token': api_key})}"
    # else treat base as a directory-like API root
    if not base.endswith('/'):
        base = base + '/'
    # try /lookup/IP then /IP
    u1 = urljoin(base, f"lookup/{ip}")
    u2 = urljoin(base, ip)
    # prefer u1 with query params; the service can ignore unknown params
    q = urlencode({'api_key': api_key, 'key': api_key, 'token': api_key})
    return f"{u1}?{q}"

def query_ip(ip, base_url, api_key, timeout=10):
    if not api_key:
        return {
            "ip": ip, "source": "ipquery", "status": "dry-run",
            "reason": "missing_api_key", "ts": int(time.time())
        }
    url = build_url(base_url, ip, api_key)
    req = Request(url, headers={"User-Agent": "GhostWired-IPQuery-Sentinel/1.0"})
    try:
        with urlopen(req, timeout=timeout) as resp:
            raw = resp.read()
            try:
                data = json.loads(raw.decode('utf-8', errors='replace'))
            except Exception:
                data = {"raw": raw.decode('utf-8', errors='replace')}
            return {
                "ip": ip, "source": "ipquery", "status": "ok",
                "http": resp.getcode(), "data": data, "ts": int(time.time())
            }
    except HTTPError as e:
        return {"ip": ip, "source": "ipquery", "status": "http_error",
                "http": e.code, "error": str(e), "ts": int(time.time())}
    except URLError as e:
        return {"ip": ip, "source": "ipquery", "status": "network_error",
                "error": str(e.reason), "ts": int(time.time())}
    except Exception as e:
        return {"ip": ip, "source": "ipquery", "status": "error",
                "error": repr(e), "ts": int(time.time())}

def main():
    ap = argparse.ArgumentParser(description="GhostWired IPQuery Guardian")
    ap.add_argument("--ip", action="append", dest="ips", help="IP address (repeatable)")
    ap.add_argument("--stdin", action="store_true", help="Read IPs from stdin")
    ap.add_argument("--log", default="logs/whisper_ipquery.log", help="Log file (JSONL)")
    ap.add_argument("--bypass", default="conf/bypass.list", help="Bypass list path")
    ap.add_argument("--base-url", default=os.getenv("IPQUERY_BASE_URL", "https://ipquery.io/api"),
                    help="Base API URL or templated URL containing {ip}")
    ap.add_argument("--api-key", default=os.getenv("IPQUERY_API_KEY", ""), help="API key/token")
    ap.add_argument("--sleep", type=float, default=float(os.getenv("IPQUERY_THROTTLE", "0.5")),
                    help="Seconds to sleep between requests")
    args = ap.parse_args()

    candidates = []
    if args.ips:
        candidates.extend(args.ips)
    if args.stdin:
        for line in sys.stdin:
            s = line.strip()
            if s: candidates.append(s)

    # unique while preserving order
    seen = set(); ips = []
    for ip in candidates:
        if ip not in seen:
            seen.add(ip); ips.append(ip)

    nets, singles = load_bypass(args.bypass)

    os.makedirs(os.path.dirname(args.log), exist_ok=True)
    out = open(args.log, "a", encoding="utf-8")

    for ip in ips:
        try:
            # validate IP
            ip_address(ip)
        except Exception:
            out.write(json.dumps({"ip": ip, "status":"invalid_ip", "ts": int(time.time())}) + "\n")
            continue

        if is_bypassed(ip, nets, singles):
            out.write(json.dumps({"ip": ip, "status":"bypassed", "ts": int(time.time())}) + "\n")
            continue

        entry = query_ip(ip, args.base_url, args.api_key)
        out.write(json.dumps(entry, ensure_ascii=False) + "\n")
        out.flush()
        time.sleep(max(0.0, args.sleep))

    out.close()

if __name__ == "__main__":
    main()
