''' Functions (https://tinyurl.com/5n7tdrfr) '''

# Basic function
def basic_function():
    print('The basic function has no arguments and returns nothing')

# Function with args and return value
def add(val1, val2):
    print(f'Adding {val1} and {val2}')
    return val1+val2

# Function with default arguments
def default_arguments(a, b=10, c='Metromonacle'):
    print(f'Received arguments a={a}, b={b}, c={c}')


# Calling functions
print(f'Calling basic_function.  Returned: {basic_function()}')
print(f'Calling add with 20 and 30.  Returned: {add(20,30)}')
print(f'Calling default_arguments(100, 200) {default_arguments(100,200)}')

# Calling a function with the wrong number of arguments
try:
    add()
except TypeError as e:
    print(e)
    print(f'No arguments passed cause exception')

# Retrieving the function object and calling from the reference
f1 = basic_function
print(f'The basic_function is object {f1}')
f1()


