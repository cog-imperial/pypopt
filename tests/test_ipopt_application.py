import pytest
from tests.conftest import app


def test_can_set_string_options(app):
    assert app.options().set_string_value('output_file', '/tmp/test.file')
    assert app.options().get_string_value('output_file') == '/tmp/test.file'


def test_can_set_numeric_options(app):
    assert app.options().set_numeric_value('tol', 1e-6)
    assert app.options().get_numeric_value('tol') == 1e-6
