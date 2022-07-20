''' Modules and Import - Part B: Importing a module (https://tinyurl.com/2p96864r) '''

import math
import sys
import os
import e10a_module_definition
from e10a_module_definition import CONSTANT2

print(f'Import path: {sys.path}')
print(f'Current working directory: {os.getcwd()}')

# Importing the module loaded the namespace
print(f'Constant 1 = {e10a_module_definition.CONSTANT1}')

# Using the from keyword on import added CONSTANT2 to the global namespace
print(f'Constant 2 = {CONSTANT2}')

# Call a function in the module
two_digit_sum = e10a_module_definition.function_a(55, 45)
print(f'The value of the two digit sum is: {two_digit_sum}')
