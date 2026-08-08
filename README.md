# Works-by-Worrell: Daemon Global Agent Setup (`wbw-daemon`)

This repository houses the global configuration plugin, bootstrapper, and installation scripts for the **Works-by-Worrell Daemon** (the Antigravity agent). 

---

## 1. System Architecture & Design Patterns

```
wbw-daemon/
├── .githooks/            # Shared, version-controlled git validation hooks
│   └── commit-msg        # Enforces Conventional Commit standards with issue tags
├── bin/                  # Executable daemon bootstrapper and MCP bridge
│   ├── mcp-bridge.sh     # Acquires port 8080 lock, starts gcloud proxy, and initializes SSE transport
│   └── wbw-daemon        # Primary CLI entrypoint; fetches identity and launches agy
├── rules/                # Fallback rule definitions if dynamic fetching fails
│   └── base.md           # Local fallback identity rules
├── install.sh            # Global workspace installer script
├── mcp_config.json       # Antigravity tool schema pointing to the mcp-bridge.sh
└── plugin.json           # Antigravity plugin manifest
```

### Core Design Patterns
*   **Decentralized Bootstrapping:** Bypasses legacy monolithic `.bashrc` constraints by dynamically symlinking the daemon CLI into `~/.local/bin/wbw-daemon`.
*   **Stateless Initialization:** `wbw-daemon` does not hardcode Warlock endpoint state. It fetches identity on the fly using strict authenticated `curl` calls against Google Cloud Run APIs.
*   **Subprocess Proxy Management:** `mcp-bridge.sh` takes strict ownership of the Warlock `gcloud run services proxy`. It uses file-descriptor locking (`flock`) and TCP polling to ensure collision-free tunnel bootstrapping when Antigravity requests MCP tools.

---

## 2. Local Development & Making Changes

### Editing the Plugin Architecture
Changes to `mcp_config.json`, `plugin.json`, or the `rules/` directory take effect automatically the next time you boot `wbw-daemon`, provided you are actively working in the workspace where `install.sh` was run.

### Editing Executables (`bin/` or `install.sh`)
If you modify `bin/mcp-bridge.sh`, `bin/wbw-daemon`, or `install.sh`, you should re-run `./install.sh` locally to ensure any dynamically generated absolute paths in `mcp_config.json` remain accurate, and to ensure symlinks in `~/.local/bin` correctly point to your working branch modifications.

### Testing Changes
1. Apply your changes locally.
2. Run `./install.sh`.
3. Boot `wbw-daemon` from a clean terminal to verify Warlock MCP initialization and identity fetching logic.
4. Execute diagnostic tools to ensure `mcp-bridge.sh` hasn't destabilized the SSE connection.
