''' The Standard Library - JSON (https://tinyurl.com/ypsfs42f) '''

"""
    JSON is commonly used with data APIs and REST calls.

    The JSON module is included as part of Python's Standard Library.
"""

import json

# Parse a JSON blob into a dictionary
# The JSON library requires property names enclosed in double quotes
print('*** Example 1: Parsing a JSON blob into a dictionary ***')
userJSON = '{"first_name": "John", "last_name": "Doe", "age": 30}'
user = json.loads(userJSON)
print(user)
print(user['first_name'])

# Convert a dictionary into JSON
print('\n*** Example 2: Exporting a dictionary to JSON ***')
car = {'make': 'Ford', 'model': 'Mustang', 'year': 1970}
carJSON = json.dumps(car)
print(carJSON)