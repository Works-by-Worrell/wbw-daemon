import io
from pathlib import Path
from unittest.mock import AsyncMock, patch

import pytest
from google.antigravity.types import McpStdioServer

from wbw_daemon.main import interactive_loop


@pytest.mark.asyncio
@patch("wbw_daemon.main.Agent")
@patch("wbw_daemon.main.LocalAgentConfig")
async def test_interactive_loop_exit_command(mock_config_cls, mock_agent_cls):
    in_stream = io.StringIO("exit\n")
    out_stream = io.StringIO()

    mock_agent = AsyncMock()
    mock_agent_cls.return_value = mock_agent
    mock_agent.__aenter__.return_value = mock_agent

    await interactive_loop(in_stream=in_stream, out_stream=out_stream)

    output = out_stream.getvalue()
    assert "> " in output


@pytest.mark.asyncio
@patch("wbw_daemon.main.Agent")
@patch("wbw_daemon.main.LocalAgentConfig")
async def test_interactive_loop_chat(mock_config_cls, mock_agent_cls):
    in_stream = io.StringIO("hello\nexit\n")
    out_stream = io.StringIO()

    mock_agent = AsyncMock()
    mock_agent_cls.return_value = mock_agent
    mock_agent.__aenter__.return_value = mock_agent

    mock_response = AsyncMock()

    class AsyncGenMock:
        def __init__(self, items):
            self.items = items
            self.iter = iter(items)

        def __aiter__(self):
            return self

        async def __anext__(self):
            try:
                return next(self.iter)
            except StopIteration:
                raise StopAsyncIteration

    def iter_mock():
        return AsyncGenMock(["Hi", " there"]).__aiter__()

    mock_response.__aiter__.side_effect = iter_mock
    mock_agent.chat.return_value = mock_response

    await interactive_loop(in_stream=in_stream, out_stream=out_stream)

    output = out_stream.getvalue()
    assert "Hi there\n" in output
    mock_agent.chat.assert_called_once_with("hello")


@pytest.mark.asyncio
@patch("wbw_daemon.main.Agent")
@patch("wbw_daemon.main.LocalAgentConfig")
async def test_interactive_loop_configures_daemon(mock_config_cls, mock_agent_cls):
    in_stream = io.StringIO("exit\n")
    out_stream = io.StringIO()

    mock_agent = AsyncMock()
    mock_agent_cls.return_value = mock_agent
    mock_agent.__aenter__.return_value = mock_agent

    await interactive_loop(in_stream=in_stream, out_stream=out_stream)

    mock_config_cls.assert_called_once()
    kwargs = mock_config_cls.call_args.kwargs

    assert "capabilities" in kwargs
    capabilities = kwargs["capabilities"]
    from google.antigravity.types import CapabilitiesConfig

    assert isinstance(capabilities, CapabilitiesConfig)
    assert capabilities.enable_subagents is True

    assert "mcp_servers" in kwargs
    servers = kwargs["mcp_servers"]
    assert len(servers) == 1
    server = servers[0]

    assert isinstance(server, McpStdioServer)
    assert server.name == "warlock"
    assert server.command == "docker"

    env_file = str(Path.home() / ".wbw" / ".env")
    expected_args = [
        "run",
        "-i",
        "--rm",
        "--env-file",
        env_file,
        "ghcr.io/works-by-worrell/warlock-mcp:latest",
        "--transport",
        "stdio",
    ]
    assert server.args == expected_args
