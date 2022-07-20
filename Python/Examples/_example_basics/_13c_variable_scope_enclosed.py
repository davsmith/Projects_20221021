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

global1 = 'global scope'

def demo_outer_scope():
    global global1

    ''' Variables defined within a function have Local scope '''
    inner1 = 'enclosed scope'
    outer1 = 'enclosed scope'
    global1 = 'enclosed scope'
    
    def demo_inner_scope():
        nonlocal outer1
        global global1

        inner1 = 'local scope'
        outer1 = 'local scope'
        global1 = 'local scope'

        print(f'From inner function: global1={inner1}, outer1={outer1}, inner1={inner1}')

    print(f'From outer function: global1={inner1}, outer1={outer1}, inner1={inner1}')
    demo_inner_scope()
    print(f'From outer function: global1={inner1}, outer1={outer1}, inner1={inner1}')

demo_outer_scope()