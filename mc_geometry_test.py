"""Tests for MineCraft geometry class with MCVector, MCRectangle, etc."""
from pytest import approx
import pytest
from mc_geometry import MCVector, MCRectangle, Direction


class TestMCVector:
    """Tests for vector class (MCVector)"""

    def test_endpoint_flat_north(self) -> tuple:
        """Testing comparison of very close floating point numbers"""
        vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Flat,
                       theta=Direction.North)
        assert vec.mc_end_point == approx((0, 0, -1), abs=.1)

    def test_endpoint_flat_south(self) -> tuple:
        """Testing comparison of very close floating point numbers"""
        vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Flat,
                       theta=Direction.South)
        print(vec)
        assert vec.mc_end_point == approx((0, 0, 1), abs=.1)

    def test_endpoint_flat_east(self) -> tuple:
        """Testing comparison of very close floating point numbers"""
        vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Flat,
                       theta=Direction.East)
        print(vec)
        assert vec.mc_end_point == approx((1, 0, 0), abs=.1)

    def test_endpoint_flat_west(self) -> tuple:
        """Testing comparison of very close floating point numbers"""
        vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Flat,
                       theta=Direction.West)
        print(vec)
        assert vec.mc_end_point == approx((-1, 0, 0), abs=.1)

    def test_endpoint_up_north(self) -> tuple:
        """Testing comparison of very close floating point numbers"""
        vec = MCVector(origin=(0, 0, 0), length=1, phi=Direction.Up,
                       theta=Direction.North)
        print(vec)
        assert vec.mc_end_point == approx((0, 1, 0), abs=.1)

    def test_endpoint_up_north_west(self) -> tuple:
        """Testing comparison of very close floating point numbers"""
        vec = MCVector(origin=(0, 0, 0), length=1, phi=45,
                       theta=45)
        print(vec)
        assert vec.mc_end_point == approx((.5, .7071, .5), abs=.1)

    # @pytest.mark.skip
    def test_endpoint_non_zero_origin(self) -> tuple:
        """Testing comparison of very close floating point numbers"""
        vec = MCVector(origin=(1, 1, 1), length=1, phi=45,
                       theta=45)
        print(vec)
        assert vec.mc_end_point == approx((1.5, 1.7071, 1.5), abs=.1)


class TestMCRectangle:
    """Tests for the MineCraft Rectangle class (MCRectangle)"""
    @pytest.mark.skip
    def test_rectangle_with_zero_origin_east(self):
        """Default case where the origin is 0, 0, 0"""
        rec1 = MCRectangle(origin=(0, 0, 0), length=5,
                           height=3, phi=0, theta=Direction.East)
        assert rec1.opposite == approx((4, 3, 0), abs=.1)
