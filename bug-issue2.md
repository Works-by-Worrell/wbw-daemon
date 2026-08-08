### Context & Why
The agent's MCP bridge is failing to launch in the current CLI session because the `mcp_config.json` uses a relative path (`bin/mcp-bridge.sh`) for its executable. Antigravity requires an absolute path to invoke server executables correctly, as the daemon processes don't guarantee matching working directories.

### Technical Implementation Plan
- Modify `mcp_config.json` to resolve `bin/mcp-bridge.sh` using an absolute path.
- Since `mcp_config.json` doesn't support bash variable expansion natively (like `$AGY_WORKSPACE_ROOT`), this path needs to be dynamically injected during `install.sh`.
- Update `install.sh` to rewrite `mcp_config.json` with the absolute `$AGY_WORKSPACE_ROOT/.agents/plugins/wbw-daemon/bin/mcp-bridge.sh` path when it executes.

### Acceptance Criteria
- [ ] `mcp_config.json` is generated with an absolute path to `mcp-bridge.sh`.
- [ ] The MCP server launches without error and tools are registered in the agent context.

### Verification & Testing Instructions
Run `./install.sh`. Check the contents of `.agents/plugins/wbw-daemon/mcp_config.json` to verify the absolute path exists. Boot `agy` and confirm the Warlock MCP tools are loaded.
