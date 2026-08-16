#!/bin/bash
# Command Gatekeeper Hook script for wbw-daemon
# Reads PreToolUse JSON payload from stdin and outputs decision on stdout.

python3 -c '
import sys, json, re, os

try:
    data = json.load(sys.stdin)
    cmd = data.get("toolCall", {}).get("args", {}).get("CommandLine", "")
    if not cmd:
        cmd = data.get("toolCall", {}).get("args", {}).get("commandLine", "")
    
    # Blacklist pattern: Require interactive confirmation for remote, cloud deploy, or destructive actions
    blacklist = r"^\s*(git\s+push|gh\s+pr\s+create|gcloud\s+(run\s+services\s+update|deploy|deployments)|docker\s+push|terraform\s+apply|rm\s+-rf)"
    
    if re.search(blacklist, cmd):
        # Check if the agent applied the bypass key after getting ask_question approval
        if os.environ.get("GATEKEEPER_BYPASS") == "1" or "GATEKEEPER_BYPASS=1" in cmd:
            print(json.dumps({"decision": "allow"}))
        else:
            print(json.dumps({
                "decision": "deny", 
                "reason": "Destructive command blocked by gatekeeper. Use ask_question tool to request explicit authorization from the user. If approved, retry the exact command prefixed with GATEKEEPER_BYPASS=1"
            }))
    else:
        print(json.dumps({"decision": "allow"}))
except Exception:
    print(json.dumps({"decision": "allow"}))
'
