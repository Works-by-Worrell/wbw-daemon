# Works-by-Worrell: Workspace Setup & New User Guide

Welcome to the Works-by-Worrell engineering ecosystem. This guide dictates how to initialize a fresh workstation and securely boot your agentic development environment.

## 1. Prerequisites
Before installing the daemon, ensure you have the following configured on your machine:
*   **Google Cloud CLI (`gcloud`)**: Must be installed, and you must run `gcloud auth login` and `gcloud config set project works-by-worrell` to authenticate against the infrastructure.
*   **Node.js / npx**: Required for the `@modelcontextprotocol/server-remote` transport.
*   **Git**: Required for repository cloning and version control.

---

## 2. Workspace Initialization
We operate within a fully decentralized, multi-repo workspace structure. 

1. **Create the Workspace Root**
   Select a root directory on your machine (e.g., `~/Works-by-Worrell`).
   ```bash
   mkdir ~/Works-by-Worrell
   cd ~/Works-by-Worrell
   ```

2. **Clone the Daemon Repository**
   You must pull down this repository first to bootstrap the remaining tools.
   ```bash
   git clone https://github.com/Works-by-Worrell/wbw-daemon.git
   cd wbw-daemon
   ```

---

## 3. Installing the Daemon
The installation script will securely wire the plugin into your workspace and mutate your `.bashrc` dotfiles to establish a permanent anchor.

1. Execute the installation script:
   ```bash
   ./install.sh
   ```
2. When prompted, provide your **Workspace Root** (e.g., `/home/<user>/Works-by-Worrell`).
3. When prompted, provide your **Operator ID** (e.g., `raworre` or `spike`).
4. **Source your terminal** to load the newly injected environment variables, or simply restart your terminal application.
   ```bash
   source ~/.bashrc
   ```

---

## 4. Booting the Agent
With installation complete, your system `PATH` now contains the `wbw-daemon` command.

1. Navigate to any repository within your workspace root.
2. Execute the daemon:
   ```bash
   wbw-daemon
   ```
3. The daemon will automatically use your authentication context to query the Warlock MCP server, download your personalized Identity Profile, spin up the secure cloud-tunnel proxy, and drop you into an initialized Antigravity session.

---

## 5. Cloning Remaining Repositories
Once your daemon is running, you can leverage it (or standard git commands) to pull down the remainder of the ecosystem architecture:
*   `wbw-architecture`
*   `wbw-config`
*   `warlock-mcp`
*   `eldritch-harvester`
*   (And any other active projects).
