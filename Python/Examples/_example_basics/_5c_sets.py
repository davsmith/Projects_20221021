''' Lists, Tuples, and Sets (https://tinyurl.com/mr3t2ny5) '''

# Create a set using {}
fruits = {'avocado', 'apple', 'banana', 'strawberry', 'cherry', 'tomato'}
vegetables = {'carrot', 'corn', 'spinach', 'avocado', 'tomato', 'lettuce'}

print(f'The fruit set is {fruits}')
print(f'The vegetable set is {vegetables}')


# Create an empty set with set() as {} creates a dictionary
starter_set = set()

# Add an item to the set, then confirm it can't be added again
print(f'The starter_set has {len(starter_set)} elements')
starter_set.add('something')
print(f'After adding something the starter_set has {len(starter_set)} elements')
starter_set.add('something')
print(f'After adding something again, the starter_set has {len(starter_set)} elements')

# Check if something is in the set
print(f'Checking if something is in the set: {"something" in starter_set}')
print(f'Checking if nothing is in the set: {"nothing" in starter_set}')

# Use .remove to remove a member from the list
# The .discard method does the same, but does not raise an exception
#   if the item to remove is not in the set
# 
starter_set.remove('something')
# starter_set.discard('something')
print(f'After removing something, the starter_set has {len(starter_set)} elements')

# Show some set math methods
print(f'fruits.intersection(vegetables): {fruits.intersection(vegetables)}')
print(f'fruits.union(vegetables): {fruits.union(vegetables)}')
print(f'fruits.difference(vegetables): {fruits.difference(vegetables)}')

# Add the elements of each set into a new set
combined_set = set()
combined_set.update(fruits)
combined_set.update(vegetables)
print(f'Add two sets to an empty set yields: {combined_set}')

# Empty a set
combined_set.clear()
print(f'Emptied the set: {combined_set}')

# Delete the set
del combined_set
print('Deleted the combined set')