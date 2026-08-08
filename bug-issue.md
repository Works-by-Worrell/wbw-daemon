### Context & Why
The current `install.sh` hardcodes the plugin symlink target to `$HOME/.agents/plugins/wbw-daemon`, which is an invalid Antigravity customization root. 
Because the script symlinks the plugin into a dead zone, the plugin remains invisible to the CLI at boot. 
The correct root should be the workspace root (`$AGY_WORKSPACE_ROOT/.agents/plugins/wbw-daemon`) or the global root (`$HOME/.gemini/config/plugins/wbw-daemon`).

### Technical Implementation Plan
- Update `install.sh` to construct `PLUGIN_TARGET` correctly using `$AGY_WORKSPACE_ROOT/.agents/plugins/wbw-daemon`.
- Ensure the parent directory `$AGY_WORKSPACE_ROOT/.agents/plugins` is created before symlinking.
- (Optional but helpful) Remove the old incorrect directory path `$HOME/.agents/plugins/wbw-daemon` if it was accidentally created by previous runs.

### Acceptance Criteria
- [ ] `install.sh` correctly resolves the valid plugin target directory.
- [ ] The plugin symlink is created in `$AGY_WORKSPACE_ROOT/.agents/plugins/wbw-daemon`.

### Verification & Testing Instructions
Execute `./install.sh`. Verify that the symlink `wbw-daemon` exists inside the active workspace's `.agents/plugins/` directory and that the CLI properly detects the plugin at boot.
