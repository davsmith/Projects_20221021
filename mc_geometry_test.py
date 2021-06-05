"""An example of a test module for mc_geometry.py"""
from pytest import approx
from mc_geometry import MCVector, Direction


def test_endpoint_flat_north() -> tuple:
    """Testing comparison of very close floating point numbers"""
    vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Flat,
                   theta=Direction.North)
    assert vec.mc_end_point == approx((0, 0, -1), abs=.1)


def test_endpoint_flat_south() -> tuple:
    """Testing comparison of very close floating point numbers"""
    vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Flat,
                   theta=Direction.South)
    print(vec)
    assert vec.mc_end_point == approx((0, 0, 1), abs=.1)


def test_endpoint_flat_east() -> tuple:
    """Testing comparison of very close floating point numbers"""
    vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Flat,
                   theta=Direction.East)
    print(vec)
    assert vec.mc_end_point == approx((1, 0, 0), abs=.1)


def test_endpoint_flat_west() -> tuple:
    """Testing comparison of very close floating point numbers"""
    vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Flat,
                   theta=Direction.West)
    print(vec)
    assert vec.mc_end_point == approx((-1, 0, 0), abs=.1)


def test_endpoint_up_north() -> tuple:
    """Testing comparison of very close floating point numbers"""
    vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Up,
                   theta=Direction.North)
    print(vec)
    assert vec.mc_end_point == approx((0, 1, 0), abs=.1)


def test_endpoint_up_north_west() -> tuple:
    """Testing comparison of very close floating point numbers"""
    vec = MCVector(origin=(0, 0, 0), length=1, phi=45,
                   theta=45)
    print(vec)
    assert vec.mc_end_point == approx((.5, .7071, .5), abs=.1)
