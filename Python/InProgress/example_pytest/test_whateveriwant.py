""" Tests for the experiment2.py file """
import math
import pytest
from numpy.testing import assert_almost_equal
from div_func import divide


def test_valid_cases():
    """ The test for the inc function """
    assert divide(12, 3) == 4
    assert divide(-5) == -5


def test_handle_divide_by_zero():
    """ Confirm an exception is raised when divide by zero occurs """
    with pytest.raises(ZeroDivisionError)as execinfo:
        assert 15/0 == 0
    print(execinfo)


def test_handle_floating_point_values():
    """ Demonstrate how to handle floating point numbers that are near, but not quite zeros """
    result = math.sin(math.pi)
    print(f"\nComparing {result} to 0")
    assert_almost_equal(result, 0, 3)


def test_handle_exception():
    """  Try exception handling """
    with pytest.raises(Exception) as execinfo:
        raise Exception('some info')
    # these asserts are identical; you can use either one
    assert execinfo.value.args[0] == 'some info'
