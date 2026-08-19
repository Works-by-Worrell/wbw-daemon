import asyncio
import sys
from pathlib import Path

from google.antigravity import Agent, LocalAgentConfig, policy
from google.antigravity.types import (
    AgentBehavior,
    BuiltinTools,
    CapabilitiesConfig,
    McpStdioServer,
)


async def read_line(stream):
    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(None, stream.readline)


def get_identity_prompt() -> str:
    identity_path = Path(".agents/plugins/wbw-daemon/rules/identity.local.md")
    if identity_path.exists():
        return identity_path.read_text()
    # Fallback to basic stub if file not found
    return "You are Daemon, the Works-by-Worrell core Orchestrator agent."


async def interactive_loop(in_stream=sys.stdin, out_stream=sys.stdout):
    env_file = str(Path.home() / ".wbw" / ".env")

    api_key = None
    try:
        with open(env_file, "r") as f:
            for line in f:
                line = line.strip()
                if line.startswith("DAEMON_GEMINI_API_KEY="):
                    val = line.split("=", 1)[1].strip(" \"'")
                    if val:
                        api_key = val
                    break
    except FileNotFoundError:
        pass

    if not api_key:
        print("Error: DAEMON_GEMINI_API_KEY is required in ~/.wbw/.env")
        sys.exit(1)

    config_kwargs = dict(
        system_instructions=get_identity_prompt(),
        capabilities=CapabilitiesConfig(
            enable_subagents=True,
            enabled_tools=[BuiltinTools.ASK_QUESTION],
            agent_behavior=AgentBehavior.INTERACTIVE,
        ),
        app_data_dir=str(Path.home() / ".gemini" / "antigravity-cli"),
        mcp_servers=[
            McpStdioServer(
                name="warlock",
                command="docker",
                args=[
                    "run",
                    "-i",
                    "--rm",
                    "--env-file",
                    env_file,
                    "ghcr.io/works-by-worrell/warlock-mcp:latest",
                    "--transport",
                    "stdio",
                ],
            )
        ],
        policies=[policy.allow_all()],
    )
    if api_key:
        config_kwargs["api_key"] = api_key

    config = LocalAgentConfig(**config_kwargs)

    async with Agent(config) as agent:
        while True:
            out_stream.write("> ")
            out_stream.flush()
            line = await read_line(in_stream)
            if not line:
                out_stream.write("\n")
                break

            line = line.strip()
            if line == "exit":
                break

            if line:
                try:
                    response = await agent.chat(line)
                    async for chunk in response:
                        out_stream.write(chunk)
                        out_stream.flush()
                    out_stream.write("\n")
                except Exception as e:
                    out_stream.write(f"\nError: {str(e)}\n")


def main():
    try:
        asyncio.run(interactive_loop())
    except KeyboardInterrupt:
        print("\nExiting.")


if __name__ == "__main__":
    main()
