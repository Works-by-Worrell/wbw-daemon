#!/bin/bash
set -e

WARLOCK_SERVICE="${WBW_WARLOCK_SERVICE:-warlock-mcp-nprd}"
WARLOCK_REGION="${WBW_WARLOCK_REGION:-us-central1}"

if (echo > /dev/tcp/127.0.0.1/8080) >/dev/null 2>&1; then
    echo "Warlock proxy is already running on port 8080."
else
    echo "Starting Warlock proxy for MCP Inspector on http://localhost:8080 ..."
    # Run the proxy in the background
    gcloud run services proxy $WARLOCK_SERVICE --region=$WARLOCK_REGION --port 8080 >/dev/null 2>&1 &
    PROXY_PID=$!

    trap 'kill $PROXY_PID 2>/dev/null' EXIT

    echo "Waiting for proxy to initialize..."
    while ! (echo > /dev/tcp/127.0.0.1/8080) >/dev/null 2>&1; do
        sleep 0.5
    done
fi
echo "Proxy is ready!"

echo "=========================================================="
echo "    MCP Inspector is starting..."
echo "    In the web UI, choose 'SSE' and enter the URL:"
echo "    http://localhost:8080/sse"
echo "=========================================================="
echo ""

# Launch the official MCP Inspector UI
npx -y @modelcontextprotocol/inspector
