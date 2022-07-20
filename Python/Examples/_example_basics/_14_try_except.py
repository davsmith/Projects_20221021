''' Error Handling - Try/Except (https://tinyurl.com/2fv7mykr) '''

# Python uses try/except blocks to handle scenarios that don't follow
# the ordinary (golden) path
#
# Try/Except blocks can have up to four sections:  try, except, else, and finally
# Frequently only the try and except blocks are used
#
# Though a general except Exception clause can be used to catch all errors,
# it's best to be specific where possible, and to let unexpected errors
# fall through to the Python handler which will print a callstack and other
# debugging information
#

# The try block contains the code to run
# The except block runs when the specified exception is raised
print('*** Example 1: Try/except block ***')
try:
    print(f'Trying to divide one by zero {1/0}')
except ZeroDivisionError as e:
    print('Exception: Stop trying to divide by zero')

# The else block runs if there is no exception
print('\n*** Example 2: Try/except/else block ***')
try:
    print(f'Trying to divide one by three {1/3}')
except ZeroDivisionError as e:
    print('Exception: Stop trying to divide by zero')
else:
    print('else block ran.  No exception thrown.')

# The finally block runs regardless of if an exception was raised
print('\n*** Example 3: Try/except/else/finally block ***')
print('Take 1: Exception occurred')
try:
    print(f'Trying to divide one by three {1/3}')
except ZeroDivisionError as e:
    print('Exception: Stop trying to divide by zero')
else:
    print('All is well.  No exception thrown.')
finally:
    print('The finally block completed')

print('\nTake 2: No exception occurred')
try:
    print(f'Trying to divide one by three {1/3}')
except ZeroDivisionError as e:
    print('Exception: Stop trying to divide by zero')
else:
    print('All is well.  No exception thrown.')
finally:
    print('The finally block completed')
