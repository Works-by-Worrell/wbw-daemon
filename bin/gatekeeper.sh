#!/bin/bash
# Command Gatekeeper Hook script for wbw-daemon
# Reads PreToolUse JSON payload from stdin and outputs decision on stdout.

python3 -c '
import sys, json, re

try:
    data = json.load(sys.stdin)
    cmd = data.get("toolCall", {}).get("args", {}).get("CommandLine", "")
    if not cmd:
        cmd = data.get("toolCall", {}).get("args", {}).get("commandLine", "")
    
    if re.search(r"^\s*git\s+push", cmd) or re.search(r"^\s*gh\s+pr\s+create", cmd):
        print(json.dumps({"decision": "ask", "reason": "Remote action requires Push Package approval breakpoint"}))
    else:
        print(json.dumps({"decision": "allow"}))
except Exception:
    print(json.dumps({"decision": "allow"}))
'
