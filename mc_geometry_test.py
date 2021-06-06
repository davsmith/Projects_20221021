"""Tests for MineCraft geometry class with MCVector, MCRectangle, etc."""
from pytest import approx
# import pytest
from mc_geometry import MCVector, MCRectangle, Direction


class TestMCVector:
    """Tests for vector class (MCVector)"""

    def test_endpoint_flat_north(self) -> tuple:
        """Testing comparison of very close floating point numbers"""
        vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Flat,
                       theta=Direction.North)
        assert vec.end_point == approx((0, 0, -1), abs=.1)

    def test_endpoint_flat_south(self) -> tuple:
        """Testing comparison of very close floating point numbers"""
        vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Flat,
                       theta=Direction.South)
        print(vec)
        assert vec.end_point == approx((0, 0, 1), abs=.1)

    def test_endpoint_flat_east(self) -> tuple:
        """Testing comparison of very close floating point numbers"""
        vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Flat,
                       theta=Direction.East)
        print(vec)
        assert vec.end_point == approx((1, 0, 0), abs=.1)

    def test_endpoint_flat_west(self) -> tuple:
        """Testing comparison of very close floating point numbers"""
        vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Flat,
                       theta=Direction.West)
        print(vec)
        assert vec.end_point == approx((-1, 0, 0), abs=.1)

    def test_endpoint_up_north(self) -> tuple:
        """Testing comparison of very close floating point numbers"""
        vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Up,
                       theta=Direction.North)
        print(vec)
        assert vec.end_point == approx((0, 1, 0), abs=.1)

    def test_endpoint_up_north_west(self) -> tuple:
        """Testing comparison of very close floating point numbers"""
        vec = MCVector(origin=(0, 0, 0), length=1, phi=45,
                       theta=45)
        print(vec)
        assert vec.end_point == approx((.5, .7071, .5), abs=.1)

    def test_endpoint_non_zero_origin(self) -> tuple:
        """Testing comparison of very close floating point numbers"""
        vec = MCVector(origin=(1, 2, 3), length=1, phi=45,
                       theta=45)
        print(vec)
        assert vec.end_point == approx((1.5, 2.7071, 3.5), abs=.1)


class TestMCRectangle:
    """Tests for the MineCraft Rectangle class (MCRectangle)"""

    def test_rectangle_with_zero_origin_east(self):
        """Default case where the origin is 0, 0, 0"""
        rec1 = MCRectangle(origin=(0, 0, 0), length=5,
                           height=3, theta=Direction.East)
        assert rec1.opposite == approx((5, 3, 0), abs=.1)

    def test_rectangle_with_nonzero_origin_east(self):
        """Default case where the origin is 0, 0, 0"""
        rec1 = MCRectangle(origin=(1, 1, 1), length=5,
                           height=3, theta=Direction.East)
        assert rec1.opposite == approx((6, 4, 1), abs=.1)

    def test_flat_rectangle_east(self):
        """Default case where the origin is 0, 0, 0"""
        rec1 = MCRectangle(origin=(0, 0, 0), length=5,
                           height=3, theta=Direction.East)
        rec1.is_tipped = True
        assert rec1.opposite == approx((5, 0, 3), abs=.1)

    def test_flat_rectangle_south(self):
        """Default case where the origin is 0, 0, 0"""
        rec1 = MCRectangle(origin=(0, 0, 0), length=5,
                           height=3, theta=Direction.South)
        rec1.is_tipped = True
        assert rec1.opposite == approx((3, 0, 5), abs=.1)
