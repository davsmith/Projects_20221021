""" Example of different methods of using the import statement and impact on the namespace """

import pytest

# The import statements should be at the top of the file with third party imports listed first
# In this example, the import statements are moved to methods to show the impact on the namespace
#
# Several pylint rules are disabled below so the examples can be demonstrated with Pylint errors
#  pylint: disable=wildcard-import
#  pylint: disable=import-outside-toplevel

# import * can only be called from the global namespace (see notes below)
from import_star_example import *


def test_import_without_from():
    """ Calling import with no 'from' adds the module to the namespace """
    print(f"\n*** Namespace before calling import ***\n{dir()}")
    import math
    print(f"*** Namespace after calling import ***\n{dir()}")

    # Access constants and methods by prefacing them with the module name
    print(f"Accessing a constant in the module (math.pi): {math.pi}")
    print(f"Accessing a method in the module (math.sin): {math.sin(0)}")

    # Confirm the math module was added to the namespace
    assert dir().index('math') >= 0


def test_import_with_from():
    """ Calling import with 'from' adds specified methods/constants to namespace """
    print(f"\n*** Namespace before calling import ***\n{dir()}")
    from math import pi, sin
    print(f"*** Namespace after calling import ***\n{dir()}")

    # Confirm pi and sin were added to the namespace
    assert dir().index('pi') >= 0
    assert dir().index('sin') >= 0

    # Methods and constants are accessed directly (without the module name preface)
    assert pi == 3.141592653589793
    assert sin(pi/2) == 1.0


def test_import_from_star():
    """
    Using "from <module> import *" adds all methods/constantsto the global namespace
            This is strongly discouraged because:
            - It pollutes the global namespace
            - Makes it difficult to determine the function origin when debugging
    """
    # Methods are accessed by calling directly (without the module name preface)
    first_function()
    second_function()
    third_function()
    print(dir())
