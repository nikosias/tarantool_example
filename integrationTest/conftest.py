import pytest
import argparse

def pytest_addoption(parser):
    parser.addoption("--url", default='http://localhost:80', action="store", help="url")

@pytest.fixture(autouse=True)
def url(request):
    return request.config.getoption("--url")