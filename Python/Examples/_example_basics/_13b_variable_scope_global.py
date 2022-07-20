''' Variable scope (https://tinyurl.com/ytzt5wcn) '''

"""
    Variable scope determines where variables can be accessed and values at
    different points in the program.

    When evaluation the existence and values of a variable, Python looks
    in the following scopes/order:  Local, Enclosing, Global and Built-In

    While variables early in the scope can override values later in the
    scope (e.g. Local takes precedence over Global or Built-In), it's
    rarely a good idea.
"""

# Variables defined at the module level have Global scope
global1 = 'global value'
global2 = 'global value'
global3 = 'global value'

def demo_global_scope():
    ''' Function to demonstrate Global variable scope '''

    global global3

    # A global variable can be read, but not assigned without global keyword
    print(f' 1: Can print, cannot assign global1 from local scope (no global keyword): {global1}')

    # If a global variable is assigned, the global keyword is required
    # even to access the global variable.
    try:
        print(f' 2: WILL FAIL: Try to print a global variable from local scope: {global2}')
        global2 = 'local value'
    except UnboundLocalError as e:
        print(f' 2: Cannot print w/o global keyword if assignment is attempted (global2)')

    # The global variable can be read and assigned with global keyword
    print(f' 3: Print a global variable from local scope: {global3}')
    global3 = 'local value'
    print(f' 3: Changed a global variable from local scope: {global3}')

    # If not using global keyword, the global variable must be assigned before the function call
    try:
        print(f' 4: WILL FAIL: Try to print a global variable from local scope: {global4}')
    except NameError as e:
        print(f' 4: Cannot access a global variable before declaration in the global scope (global4)')

    # Add a variable to global scope from local scope
    global global5
    global5 = "local value"
    print(f' 5: Defined a global variable from local scope (global5): {global5}')

print(f'Before calling function... global1:{global1}, global2: {global2}, global3:{global3}')
demo_global_scope()
print(f'After calling function... global1:{global1}, global2: {global2}, global3:{global3}')
print(f'   ... and global5:{global5}')

global4 = 'global value'
