import asyncio
import contextlib
import sys

from mcp.client.session import ClientSession
from mcp.client.sse import sse_client


async def read_line(stream):
    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(None, stream.readline)


@contextlib.asynccontextmanager
async def mcp_session(url: str):
    try:
        async with sse_client(url) as streams:
            async with ClientSession(streams[0], streams[1]) as session:
                await session.initialize()
                yield session
    except Exception:
        yield None


async def interactive_loop(in_stream=sys.stdin, out_stream=sys.stdout):
    async with mcp_session("http://localhost:8080/sse") as session:
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
            if line == "/tools":
                if session is None:
                    out_stream.write("MCP server offline or unreachable\n")
                else:
                    try:
                        tools = await session.list_tools()
                        tool_names = ", ".join(t.name for t in tools.tools)
                        out_stream.write(f"{tool_names}\n")
                    except Exception:
                        out_stream.write("MCP server offline or unreachable\n")
                continue
            if line:
                out_stream.write(f"Echo: {line}\n")


def main():
    try:
        asyncio.run(interactive_loop())
    except KeyboardInterrupt:
        print("\nExiting.")


if __name__ == "__main__":
    main()
