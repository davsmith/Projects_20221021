''' Modules and Import - Part A: Defining a module (https://tinyurl.com/2p96864r) '''

print('This should be displayed when the module is imported')
print(f'__name__ = {__name__}')

def function_a(val1=5, val2=10):
    print(f'Running function_a with {val1} and {val2}.')
    return(val1+val2)

def function_b(val1=5, val2=10):
    print(f'Running function_b with {val1} and {val2}.')
    return(val1*val2)

CONSTANT1 = 1.2345
CONSTANT2 = 42

# If the __name__ variable is __main__ the code is running standalone
if __name__ == '__main__':
    print(f'Code is running standalone, so run some tests.')
else:
    print('This module has been imported')