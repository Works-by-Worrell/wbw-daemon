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
    
    # Blacklist pattern: Require interactive confirmation for remote, cloud deploy, or destructive actions
    blacklist = r"^\s*(git\s+push|gh\s+pr\s+create|gcloud\s+(run\s+services\s+update|deploy|deployments)|docker\s+push|terraform\s+apply|rm\s+-rf)"
    
    if re.search(blacklist, cmd):
        print(json.dumps({"decision": "ask", "reason": "Remote, cloud deploy, or destructive action requires approval breakpoint"}))
    else:
        print(json.dumps({"decision": "allow"}))
except Exception:
    print(json.dumps({"decision": "allow"}))
'
