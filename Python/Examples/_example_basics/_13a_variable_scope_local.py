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

def demo_local_scope():
    ''' Variables defined within a function have Local scope '''
    
    local_val = 'local value'
    print(f'Print a local variable from local scope: {local_val}')

# Local scope - Define and print a variable (in the function)
demo_local_scope()

# Try to access the local variable from the Global scope
# It will raise a NameError exception
print(f'Print a local variable from Global scope: {local_val}')
