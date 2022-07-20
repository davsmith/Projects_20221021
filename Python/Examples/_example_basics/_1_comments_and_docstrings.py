''' Comments and DocStrings (https://tinyurl.com/2p93f9hv) '''

from example_formatter import ExampleFormatter
ex = ExampleFormatter()

# ex = ExampleFormatter()

#
# Single line comments start with a hash symbol
#

# This is a single line comment

#
# Multi-line comments are demarcated with three quotes (""")
# or three apostrophes (''')
#
""" Comment line 1
    Comment line 2
    Comment line 3 """

''' Comment line 1
    Comment line 2
    Comment line 3 '''

#
# Docstrings are multi-line comments which occur at the begining of a module
# or immediately after a function definition.
#
# They can be displayed with <module>.__doc__ or <method>.__doc__
#
print(__doc__)

def simple_function():
    ''' An example function to illustrate docstrings '''
    a = 20
    b = 30
    c = a + b

ex.new_example('Print the docstring for an object using __doc__')
print(simple_function.__doc__)



