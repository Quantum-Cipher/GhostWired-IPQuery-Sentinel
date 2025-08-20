#!/usr/bin/env python3
"""
Eternum — GhostWired Watchdog: IPQuery Guardian
Queries ipquery.io for IP intel, appends JSON lines to logs/whisper_ipquery.log
Usage:
  TARGET_IP=8.8.8.8 ./bin/ipqwery_guardian.py
  ./bin/ipqwery_guardian.py                # queries current client IP
"""
import json, sys, os, datetime, pathlib, urllib.request, urllib.error

def fetch(ip=None, fmt='json'):
    base = 'https://api.ipquery.io/'
    url = base + (ip or '') + f'?format={fmt}'
    req = urllib.request.Request(
        url,
        headers={'Accept':'application/json','User-Agent':'Eternum-Ghostwired/1.0'}
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        charset = resp.headers.get_content_charset() or 'utf-8'
        return json.loads(resp.read().decode(charset))

def main():
    ip = os.environ.get('TARGET_IP') or (sys.argv[1] if len(sys.argv) > 1 else '')
    data = fetch(ip if ip else None)

    now = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + 'Z'
    entry = {
        'timestamp': now,
        'source': 'ipquery.io',
        'ip': data.get('ip'),
        'location': data.get('location', {}),
        'isp': data.get('isp', {}),
        'risk': data.get('risk', {})
    }

    root = pathlib.Path(__file__).resolve().parents[1]
    log_dir = root / 'logs'
    log_dir.mkdir(parents=True, exist_ok=True)
    log_file = log_dir / 'whisper_ipquery.log'

    with log_file.open('a', encoding='utf-8') as f:
        f.write(json.dumps(entry, separators=(',', ':'), sort_keys=True) + '\n')

    print(json.dumps(entry, indent=2, sort_keys=True))

if __name__ == '__main__':
    try:
        main()
    except urllib.error.URLError as e:
        print(json.dumps({'error': 'network', 'detail': str(e)}))
        sys.exit(1)
    except Exception as e:
        print(json.dumps({'error': 'runtime', 'detail': str(e)}))
        sys.exit(1)
