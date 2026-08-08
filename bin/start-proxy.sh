#!/bin/bash
set -e

WARLOCK_SERVICE="${WBW_WARLOCK_SERVICE:-warlock-mcp-nprd}"
WARLOCK_REGION="${WBW_WARLOCK_REGION:-us-central1}"

echo "Starting Warlock proxy for MCP Inspector on http://localhost:8080 ..."
echo "Press Ctrl+C to terminate."
echo ""

gcloud run services proxy $WARLOCK_SERVICE --region=$WARLOCK_REGION --port 8080
