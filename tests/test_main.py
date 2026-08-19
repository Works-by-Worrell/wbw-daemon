import io
from pathlib import Path
from unittest.mock import AsyncMock, mock_open, patch

import pytest
from google.antigravity.types import McpStdioServer

from wbw_daemon.main import interactive_loop


@pytest.fixture(autouse=True)
def _mock_env_for_tests(request):
    if "without_api_key" in request.node.name:
        yield
        return
    with patch(
        "builtins.open",
        new_callable=mock_open,
        read_data="DAEMON_GEMINI_API_KEY=dummy_key\n",
    ) as m:
        yield m


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
    from google.antigravity.types import BuiltinTools, CapabilitiesConfig

    assert isinstance(capabilities, CapabilitiesConfig)
    assert capabilities.enable_subagents is True
    assert BuiltinTools.ASK_QUESTION in capabilities.enabled_tools

    assert "app_data_dir" in kwargs
    assert kwargs["app_data_dir"] == str(Path.home() / ".gemini" / "antigravity-cli")

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

    assert "model" in kwargs
    assert kwargs["model"] == "gemini-3.6-flash"


@pytest.mark.asyncio
@patch("wbw_daemon.main.Agent")
@patch("wbw_daemon.main.LocalAgentConfig")
async def test_interactive_loop_with_api_key(mock_config_cls, mock_agent_cls):
    in_stream = io.StringIO("exit\n")
    out_stream = io.StringIO()

    mock_agent = AsyncMock()
    mock_agent_cls.return_value = mock_agent
    mock_agent.__aenter__.return_value = mock_agent

    from unittest.mock import mock_open

    mock_open_fn = patch(
        "builtins.open",
        new_callable=mock_open,
        read_data='DAEMON_GEMINI_API_KEY="test_key_123"\n',
    )

    with mock_open_fn:
        await interactive_loop(in_stream=in_stream, out_stream=out_stream)

    mock_config_cls.assert_called_once()
    kwargs = mock_config_cls.call_args.kwargs
    assert "api_key" in kwargs
    assert kwargs["api_key"] == "test_key_123"


@pytest.mark.asyncio
@patch("wbw_daemon.main.Agent")
@patch("wbw_daemon.main.LocalAgentConfig")
async def test_interactive_loop_with_single_quoted_api_key(
    mock_config_cls, mock_agent_cls
):
    in_stream = io.StringIO("exit\n")
    out_stream = io.StringIO()

    mock_agent = AsyncMock()
    mock_agent_cls.return_value = mock_agent
    mock_agent.__aenter__.return_value = mock_agent

    from unittest.mock import mock_open

    mock_open_fn = patch(
        "builtins.open",
        new_callable=mock_open,
        read_data="DAEMON_GEMINI_API_KEY='test_key_123'\n",
    )

    with mock_open_fn:
        await interactive_loop(in_stream=in_stream, out_stream=out_stream)

    mock_config_cls.assert_called_once()
    kwargs = mock_config_cls.call_args.kwargs
    assert "api_key" in kwargs
    assert kwargs["api_key"] == "test_key_123"


@pytest.mark.asyncio
@patch("wbw_daemon.main.Agent")
@patch("wbw_daemon.main.LocalAgentConfig")
async def test_interactive_loop_without_api_key(mock_config_cls, mock_agent_cls):
    in_stream = io.StringIO("exit\n")
    out_stream = io.StringIO()

    mock_agent = AsyncMock()
    mock_agent_cls.return_value = mock_agent
    mock_agent.__aenter__.return_value = mock_agent

    mock_open_fn = patch("builtins.open", side_effect=FileNotFoundError)

    with mock_open_fn:
        with pytest.raises(SystemExit) as exc_info:
            await interactive_loop(in_stream=in_stream, out_stream=out_stream)
        assert exc_info.value.code == 1

    mock_config_cls.assert_not_called()
