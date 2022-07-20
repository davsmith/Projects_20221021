''' Conditionals and Booleans (https://tinyurl.com/cacdwbec) '''

# Conditionals take the form if <expression>: <code block>
# No parenthesis are required around the expression
#
# Expressions evaluate to a boolean value; i.e. True or False
#
# A number of things evaluate to False:
#   False, None, zero, any empty sequence or string (e.g. '', (), []),
#   any empty mapping (e.g. {})
#

# Always true
if True:
    print('The expression is true.')

# If an expresion is true, do something
status = 10

if status == 10:
    print('Status is ok')

# Use else to branch on a choice
if status > 100:
    print(f'Status ({status}) is greater than 100')
else:
    print(f'Status ({status}) is not greater than 100')

# Use elif to compare among multiple choices
if status == 1:
    print('Status is exactly equal to 1')
elif status == 5:
    print('Status is exactly equal to 5')
elif status == 10:
    print('Status is exactly equal to 10')
else:
    print('Status is not 1, 5, or 10')


