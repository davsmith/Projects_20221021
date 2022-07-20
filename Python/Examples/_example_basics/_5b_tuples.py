''' Lists, Tuples, and Sets (https://tinyurl.com/mr3t2ny5) '''

# A Tuple is a collection which is ordered and unchangeable.
# Duplicate elements are allowed.

# Create tuple
fruits = ('Apples', 'Oranges', 'Grapes')

# Using a constructor
# fruits2 = tuple(('Apples', 'Oranges', 'Grapes'))

# A single value tuple requires a trailing comma
fruits2 = ('Apples',)

# Get a value
print(fruits[1])

# Get the number of elements
print('# elements: {}'.format(len(fruits)))

# Confirm the value can't be changed
try:
    fruits[0] = 'Pears'
except TypeError as e:
    print("Confirmed a tuple can't be modified")

# Delete the tuple
del fruits2