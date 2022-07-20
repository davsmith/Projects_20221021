''' Functions (*args and **kwargs) - Part B (https://tinyurl.com/5n7tdrfr) '''

#
# The *args argument allows for an arbitrary set (0-n) of unnamed paramters
# to be passed to a function or method as a list.
#
# The **kwargs argument allows for an arbitrary set (0-n) of named paramters
# to be passed to a function or method as a dictionary.
#
def variable_function_args(last_name, first_name, classes=None, major="engineering", *args, **kwargs):
    print(f'Student name: {last_name}, {first_name}')
    print(f'Studen major: {major}')
    print(f'Classes: {classes}')
    print(f'Nicknames (*args): {args}')
    print(f'Other information (**kwargs): {kwargs}\n')

# Call with required arguments as positional (order implied)
variable_function_args('Smith', 'Dave')

# Call with required arguments as keywords (order arbitrary)
variable_function_args(first_name='Dave', last_name='Smith')

# Call with required and optional arguments as keywords
variable_function_args(classes=['Art', 'Physics', 'Math'], first_name='Dave', last_name='Smith', major="math")

# Call with required, optional, and arbitrary arguments
variable_function_args('Smith', 'Dave', ['Art', 'Physics', 'Math'], 'math', 'Bob', 'Robert', petname='Fluffy', eyecolor='Blue')

# Call with required, optional, and arbitrary arguments (kwargs, no args)
variable_function_args( 'Smith', 'Dave', ['Art', 'Physics', 'Math'], 'math',
                        parent_names = ['Dorothy', 'Walter'], petname='Fluffy', eyecolor='Blue')

# Invalid function calls
try:
    # Required arguments not specified
    variable_function_args()

    # Positional arguments after keyword arguments
    # variable_function_args(last_name='Smith', 'Dave')

    # Positional arguments (*args) after keyword args
    # variable_function_args('Smith', 'Dave', ['Art', 'Physics', 'Math'], major='math', 'Bob', 'Robert')

except TypeError:
    print('Function called with invalid number of arguments')
except Exception as e:
    print(f'Yikes! Unhandled excption: {e}')