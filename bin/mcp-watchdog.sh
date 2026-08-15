#!/bin/bash
# mcp-watchdog.sh — Background TCP/HTTP Watchdog for Warlock MCP Cloud Run Proxy
set -e

WARLOCK_SERVICE="${WBW_WARLOCK_SERVICE:-warlock-mcp-nprd}"
WARLOCK_REGION="${WBW_WARLOCK_REGION:-us-central1}"
CHECK_INTERVAL="${WBW_WATCHDOG_INTERVAL:-15}"

LOCK_FILE="/tmp/warlock_mcp_proxy.lock"
exec 200>"$LOCK_FILE"

ensure_proxy() {
    # Check if proxy on 8080 is responding to HTTP SSE
    if curl -s -o /dev/null -w '%{http_code}' --max-time 3 http://localhost:8080/sse | grep -q "200"; then
        return 0
    fi

    # Try simple TCP socket check as fallback
    if (echo > /dev/tcp/127.0.0.1/8080) >/dev/null 2>&1; then
        return 0
    fi

    # If un-responsive, attempt non-blocking lock to start proxy
    if flock -n 200; then
        echo "[watchdog $(date -u +'%Y-%m-%d %H:%M:%SZ')] Port 8080 down. Respawning Warlock Cloud Run proxy..."
        gcloud run services proxy "$WARLOCK_SERVICE" --region="$WARLOCK_REGION" --port 8080 >/dev/null 2>&1 &
        
        # Wait up to 5s for proxy initialization
        for i in {1..10}; do
            if (echo > /dev/tcp/127.0.0.1/8080) >/dev/null 2>&1; then
                echo "[watchdog $(date -u +'%Y-%m-%d %H:%M:%SZ')] Warlock proxy successfully restored on port 8080."
                return 0
            fi
            sleep 0.5
        done
    fi
}

# If run in daemon/loop mode
if [ "$1" = "--daemon" ]; then
    echo "[watchdog] Starting Warlock proxy watchdog loop (interval: ${CHECK_INTERVAL}s)..."
    while true; do
        ensure_proxy || true
        sleep "$CHECK_INTERVAL"
    done
else
    # One-shot check
    ensure_proxy
fi
