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

# Try all of the comparators (==, !=, >, >=, <, <=, is)
a = 1
b = 1.0
c = 2
d = 1
pi = 3.1415654

print(f'a={a}, b={b}, c={c}\n')
print(f'a == b: {a == b}')
print(f'a != c: {a != c}')
print(f'c > a: {c > a}')
print(f'a >= b: {a >= b}')
print(f'a < c: {a < c}')
print(f'a <= b: {a <= b}')

#
# Comparisons using logical operators (and, or, not)
#
print(f'(a < c) and (a == d): {(a < c) and (a == d)}')
print(f'(a < c) or (c == pi): {(a < c) or (c == pi)}')
print(f'not a is b: {not a is b}')


#
# Comparisons using is
#

# a is d because they both reference the same integer object
print(f'a is d: {a is d}')

# a is b is false because they have the same values, but different objects
print(f'a is b: {a is b}')

# Use == to compare values, and is to compare objects
list1 = ['a', 'b', 'c', 'd']
list2 = ['a', 'b', 'c', 'd']
list3 = list1

print(f'list1 (id: {id(list1)}): {list1}')
print(f'list2 (id: {id(list2)}): {list2}')
print(f'list3 (id: {id(list3)}): {list3}')

print(f'list1 == list 2: {list1 == list2}')
print(f'list1 is list 2: {list1 is list2}')
print(f'list1 is list 3: {list1 is list3}')
