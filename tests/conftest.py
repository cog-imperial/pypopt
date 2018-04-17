import pytest
from pypopt import IpoptApplication


@pytest.fixture
def app():
    return IpoptApplication()
