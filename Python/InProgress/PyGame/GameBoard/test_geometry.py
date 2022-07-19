""" Tests for the polygon functionality implemented using a class """
import pytest
import geometry


def test_using_default_arguments():
    """ Cases where no optional arguments are specified which means:
            rotation is set to a value where the bottom of the polygon is flat
    """

    expected_with_defaults = [
        (258.7785252292473, 280.90169943749476),
        (141.2214747707527, 280.90169943749476),
        (104.89434837048464, 169.09830056250527),
        (199.99999999999997, 100.0),
        (295.10565162951536, 169.09830056250524)
    ]

    polygon1 = geometry.Polygon(5, (200, 200), 100)
    vertices = polygon1.vertices
    polygon1.debug_list_vertices(vertices)
    assert len(vertices) == 5
    assert vertices == expected_with_defaults


def test_with_rotation_specified():
    """ Set rotation to 0 which means vertex 1 is straight right of center """
    expected_with_rotation_specified = [
        (300.0, 200.0),
        (230.90169943749476, 295.10565162951536),
        (119.09830056250527, 258.7785252292473),
        (119.09830056250526, 141.2214747707527),
        (230.90169943749473, 104.89434837048464)
    ]

    polygon1 = geometry.Polygon(5, (200, 200), 100, 0)
    vertices = polygon1.vertices
    polygon1.debug_list_vertices(vertices)
    assert len(vertices) == 5
    assert vertices == expected_with_rotation_specified


def test_handle_exception():
    """  An example of exception handling in Pytest """
    with pytest.raises(Exception) as execinfo:
        raise Exception('some info')
    # these asserts are identical; you can use either one
    assert execinfo.value.args[0] == 'some info'
