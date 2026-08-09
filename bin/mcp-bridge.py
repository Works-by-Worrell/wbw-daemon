#!/usr/bin/env python3
import subprocess
import threading
import sys
import urllib.request

def send_requests(endpoint_url):
    while True:
        line = sys.stdin.readline()
        if not line: break
        try:
            req = urllib.request.Request(endpoint_url, data=line.encode('utf-8'), method='POST')
            req.add_header('Content-Type', 'application/json')
            urllib.request.urlopen(req)
        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)

def main():
    proc = subprocess.Popen(['curl', '-s', '-N', 'http://localhost:8080/sse'], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    endpoint_url = None
    current_event = None
    for line in iter(proc.stdout.readline, ''):
        line = line.strip()
        if not line: continue
        if line.startswith('event: '):
            current_event = line[7:]
        elif line.startswith('data: '):
            data = line[6:]
            if current_event == 'endpoint':
                if data.startswith('/'):
                    endpoint_url = 'http://localhost:8080' + data
                else:
                    endpoint_url = data
                threading.Thread(target=send_requests, args=(endpoint_url,), daemon=True).start()
            elif current_event == 'message':
                print(data, flush=True)

if __name__ == '__main__': main()
