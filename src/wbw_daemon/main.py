import asyncio
import sys


async def read_line(stream):
    loop = asyncio.get_running_loop()
    return await loop.run_in_executor(None, stream.readline)

async def interactive_loop(in_stream=sys.stdin, out_stream=sys.stdout):
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
            out_stream.write(f"Echo: {line}\n")

def main():
    try:
        asyncio.run(interactive_loop())
    except KeyboardInterrupt:
        print("\nExiting.")

if __name__ == "__main__":
    main()
