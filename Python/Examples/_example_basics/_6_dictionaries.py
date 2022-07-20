''' Dictionaries (https://tinyurl.com/47j52zem) '''

# Creating a dictionary
auto1 = {'make':'Nissan', 'model':'Leaf', 'year':2020, 'color':'red'}
auto2 = dict(make='Toyota', model='Tacoma', year=2016, color='brown')

print(auto1)
print(auto2)

# Accessing values in a dictionary
for key in auto1:
    # Use <dict>[key] to retrieve a value
    print(f'Key: {key}, Value: {auto1[key]}')

# Confirm a KeyError is raised if the key does not exist
try:
    first_model_year = auto2['first_year']
except KeyError as e:
    print(f'Key {e} does not exist.')

# Check if a key exists
print (f'Trying to get a value: {auto2.get("year")}')
print (f'Trying to get a value: {auto2.get("first_year")}')
print (f'Trying to get a value: {auto2.get("first_year", 1900)}')

# Retrieve info about the dictionary
print(f'The dictionary contains {len(auto1)} keys')
print(f'The keys are {auto1.keys()}')
print(f'The values are {auto1.values()}')
print(f'The items are {auto1.items()}')

# Unpack a key/value pair
key, value = list(auto1.items())[0]
print(f'The first key is {key} with a value of {value}')

for key, value in auto2.items():
    print(f'Key: {key}, Value: {value}')

# Add values to a dictionary
auto1['first_year'] = 2010
print(f'Added an item: {auto1}')

# Replace a value on an existing item
auto1['color'] = 'gray'
print(f'Changed an item: {auto1}')

# Replace multiple values at once
auto1.update({'make':'Kia', 'model':'Sorento', 'year':2017})
print(f'Updated multiple items: {auto1}')

# Remove items from the dictionary
del(auto1['first_year'])
print(f'Removed first_year: {auto1}')

print(f'Popped {auto1.pop("model")} from auto1')
print(f'Now it is {auto1}')