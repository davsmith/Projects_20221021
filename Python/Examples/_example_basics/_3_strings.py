''' Strings  (https://tinyurl.com/44fpfuft) '''
from doctest import Example
from math import pi
import datetime
from example_formatter import ExampleFormatter
ex = ExampleFormatter()

example_count = 1

# Multi-line strings
ex.new_example('Multi-line strings')
str1 = '''This is the first line of a multi line string.
This is the second line
This is the third line'''

print(str1)
ex.end_example()


# Concatenate strings with the + operator, use the len function, and cast an integer to a string
ex.new_example('Using len, concatenating with +, and casting integers to a string')
print('It has a length of ' + str(len(str1)) + ' characters.')
ex.end_example()

# List the attributes of the string type
ex.new_example('Attributes of the String class')
print(dir(str1))
ex.end_example()

'''
Format using the string.format method
'''
ex.new_example('Formatting using .format()')

# Positional placeholders
print("My name is {} and I am {} years old.".format("Dave", 50))

# Numerically indexed placeholders (with one value used twice)
print("My name is {0} and I am {1} years old.  That's {1:x} in hex.".format("Dave", 50))

# Named placeholders
print("I have siblings named {sib2} and {sib1}.".format(sib1="Eric", sib2="Ruby"))

# Format a floating point to left justify, pad to 8 chars, and 3 places after the decimal
print("Format floating points like this... pi={:<8.3f}.". format(pi))

# Access values from dictionaries, lists and classes
person = {'name': 'Eric', 'age': 62}
car_list = ['Camero', 'Corvette', 'Impala', 'Tundra']

class Person():
    def __init__(self, name, age):
        self.name = name
        self.age = age

person2 = Person('Ruby', 60)

print('A guy named {0[name]} is {0[age]}.'.format(person))
print('He has had a {0[0]}, a {0[1]}, and a {0[2]}'.format(car_list))
print('\nAnother person is {0.name} and they are {0.age}.'.format(person2))
print('Again using unpacking: A person named {name} is {age}.'.format(**person))
ex.end_example()

#
# Format a date
#
# Format codes: https://docs.python.org/3/library/datetime.html#strftime-and-strptime-behavior
#
ex.new_example('Formatting a date/time')
today = datetime.datetime.now()
short_msg = 'Today is {:%b %d %Y}'.format(today)
long_msg = 'It is a {0:%A} and day {0:%j} of the year'.format(today)
print(short_msg)
print(long_msg)
ex.end_example()

'''
Format using f-strings
'''
ex.new_example('Formatting using f-strings')

# Positional placeholders
first_name = "Dave"
last_name = "Smith"
age = 51
print(f"My name is {first_name} and I am {age} years old.")


# Access values from dictionaries and lists
print(f"A guy named {person['name']} is {person['age']}.")
print(f'He has had a {car_list[0]}, a {car_list[1]}, and a {car_list[2]}')

# Inline evaluation
print(f"\nMy name is {first_name.upper()} and I am {age} years old.")
print(f"4 times 11 is equal to {4 * 11}")

# Formatting
n = 5
print(f"Add a leading zero: {n:02}")
print(f"Format to 2 decimal places: {pi:.2f}")

#
# Format a date
#
# Format codes: https://docs.python.org/3/library/datetime.html#strftime-and-strptime-behavior
#
print(f'Today is {today:%B %d %Y}')
print(f'It is a {today:%A} and day {today:%j} of the year.')
ex.end_example()

#
# Some useful methods on the string class
#
ex.new_example('Some interesting methods on the string class')
s = 'helloworld'

print('Original string: {}'.format(s))

# Get length
print('len(s): {}'.format(len(s)))

# Capitalize string
print('.capitalize: {}'.format(s.capitalize()))

# Make all uppercase
print('.upper(): {}'.format(s.upper()))

# Make all lower
print('.lower(): {}'.format(s.lower()))

# Swap case
print('.swapcase(): {}'.format(s.swapcase()))

# Non-destructive Replace
print('.replace(<sub>,<new>): {}'.format(s.replace('world', 'everyone')))

# Count
print('.count(<sub>): {}'.format(s.count('h')))

# Starts with
print('.startswith(<sub>): {}'.format(s.startswith('hello')))

# Ends with
print('.endswith(<sub>): {}'.format(s.endswith('d')))

# Split into a list
print('.split(): {}'.format(s.split()))

# Find position
print('.find(<sub>): {}'.format(s.find('r')))

# Is all alphanumeric
print('.isalnum(): {}'.format(s.isalnum()))

# Is all alphabetic
print('.isalpha(): {}'.format(s.isalpha()))

# Is all numeric
print('.isnumeric(): {}'.format(s.isnumeric()))
ex.end_example()
