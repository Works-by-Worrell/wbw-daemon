import io
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from wbw_daemon.main import interactive_loop


@pytest.mark.asyncio
async def test_interactive_loop_exit_command():
    in_stream = io.StringIO("hello\nexit\n")
    out_stream = io.StringIO()

    await interactive_loop(in_stream=in_stream, out_stream=out_stream)

    output = out_stream.getvalue()
    assert "> Echo: hello\n> " == output


@pytest.mark.asyncio
async def test_interactive_loop_eof():
    in_stream = io.StringIO("test eof\n")
    out_stream = io.StringIO()

    await interactive_loop(in_stream=in_stream, out_stream=out_stream)

    output = out_stream.getvalue()
    assert "> Echo: test eof\n> \n" == output


@pytest.mark.asyncio
@patch("wbw_daemon.main.sse_client")
@patch("wbw_daemon.main.ClientSession")
async def test_interactive_loop_tools_command(mock_client_session, mock_sse_client):
    in_stream = io.StringIO("/tools\nexit\n")
    out_stream = io.StringIO()

    # Setup mocks
    mock_sse_ctx = AsyncMock()
    mock_sse_client.return_value = mock_sse_ctx
    mock_sse_ctx.__aenter__.return_value = (AsyncMock(), AsyncMock())

    mock_session_ctx = AsyncMock()
    mock_client_session.return_value = mock_session_ctx

    mock_session = AsyncMock()
    mock_session_ctx.__aenter__.return_value = mock_session

    # Mock tool list response
    mock_tool1 = MagicMock()
    mock_tool1.name = "tool_1"
    mock_tool2 = MagicMock()
    mock_tool2.name = "tool_2"
    mock_session.list_tools.return_value = MagicMock(tools=[mock_tool1, mock_tool2])

    await interactive_loop(in_stream=in_stream, out_stream=out_stream)

    output = out_stream.getvalue()
    assert "> tool_1, tool_2\n> " in output or "tool_1" in output
    mock_session.list_tools.assert_called_once()
    mock_session.initialize.assert_called_once()


@pytest.mark.asyncio
@patch("wbw_daemon.main.sse_client")
async def test_interactive_loop_tools_command_failure(mock_sse_client):
    in_stream = io.StringIO("/tools\nexit\n")
    out_stream = io.StringIO()

    # Simulate connection failure
    mock_sse_client.side_effect = Exception("Connection refused")

    await interactive_loop(in_stream=in_stream, out_stream=out_stream)

    output = out_stream.getvalue()
    assert "MCP server offline or unreachable" in output
