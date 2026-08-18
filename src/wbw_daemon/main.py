import asyncio
import sys
from pathlib import Path

from google.antigravity import Agent, LocalAgentConfig, policy
from google.antigravity.types import McpStdioServer


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
    config = LocalAgentConfig(
        system_instructions=get_identity_prompt(),
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
                response = await agent.chat(line)
                async for chunk in response:
                    out_stream.write(chunk.text)
                    out_stream.flush()
                out_stream.write("\n")


def main():
    try:
        asyncio.run(interactive_loop())
    except KeyboardInterrupt:
        print("\nExiting.")


if __name__ == "__main__":
    main()
