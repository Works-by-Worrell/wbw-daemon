# Works-by-Worrell: SDK Orchestrator (`wbw-daemon`)

This repository houses the Python SDK Orchestrator for the **Works-by-Worrell** autonomous agent swarm. 

It utilizes the `google-antigravity` Python framework to create a stateful, terminal-based Command Center that dynamically instantiates subagents and routes workflows across your local filesystem.

---

## 1. System Architecture: The Python Pivot

Following Initiative 0009, `wbw-daemon` abandoned its legacy bash wrapper and monolithic Antigravity CLI dependencies. 

The Orchestrator is now a native Python `asyncio` application. This grants programmatic, real-time access to the swarm's internal data streams (thoughts, tool calls, status transitions) for future dashboard broadcasting.

### Core Design Patterns
*   **Decentralized Bootstrapping:** We use `uv` for rapid environment scaffolding and dependency management.
*   **Native MCP Binding:** The daemon natively binds the `warlock-mcp` Docker container using the `google-antigravity` `McpStdioServer`. The daemon manages the Docker lifecycle directly as a subprocess.
*   **Secure Credential Management:** The daemon relies on a global `~/.wbw/.env` vault to store sensitive credentials (like `GITHUB_API_KEY`), preventing token exposure in global shell profiles (`~/.bashrc`).

---

## 2. Installation & Setup

We recommend using `uv` to run the Daemon natively.

### Step 1: Secure your GitHub Token
Warlock (the MCP Server) requires a GitHub PAT to fetch your organizational definitions and agent rules dynamically.
Run the initialization script to configure your local vault:
```bash
./install.sh
```
This will prompt you for your `GITHUB_API_KEY` and securely write it to `~/.wbw/.env`.

### Step 2: Boot the Daemon
From the repository root, use `uv` to build the environment and run the entrypoint:
```bash
uv run wbw-daemon
```

---

## 3. Local Development

To actively develop the daemon or its test suite:

1. Install the development dependencies:
   ```bash
   uv pip install -e ".[dev]"
   ```
2. Run the unit tests:
   ```bash
   uv run pytest tests/
   ```
