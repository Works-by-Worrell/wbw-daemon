import io

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
