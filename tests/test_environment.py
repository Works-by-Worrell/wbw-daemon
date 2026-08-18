import pytest


def test_antigravity_installed():
    import importlib.util

    if importlib.util.find_spec("antigravity") is None:
        pytest.fail("antigravity module is not installed")


@pytest.mark.asyncio
async def test_asyncio_support():
    import asyncio

    await asyncio.sleep(0)
    assert True
