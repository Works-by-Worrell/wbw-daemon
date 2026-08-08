#!/bin/bash
set -e

LOCK_FILE="/tmp/wbw-daemon-warlock-8080.lock"

# Open file descriptor 9 and acquire an exclusive lock
exec 9>"$LOCK_FILE"
flock -n 9 || { echo "Another instance of mcp-bridge is already running." >&2; exit 1; }

echo "Starting Warlock proxy..." >&2

# Start the gcloud proxy in the background on port 8080
gcloud run services proxy warlock-mcp-nprd --region=us-central1 --port 8080 &
PROXY_PID=$!

# Ensure the proxy is terminated when this script exits
trap 'kill $PROXY_PID 2>/dev/null; rm -f "$LOCK_FILE"' EXIT

echo "Waiting for Warlock proxy to accept connections on port 8080..." >&2

# Polling loop using /dev/tcp to ensure the proxy is ready before proceeding
while ! (echo > /dev/tcp/127.0.0.1/8080) >/dev/null 2>&1; do
    sleep 0.5
done

echo "Warlock proxy is ready." >&2

# Launch the remote transport using the /sse endpoint
npx -y @modelcontextprotocol/server-remote http://localhost:8080/sse
