''' Lists, Tuples, and Sets (https://tinyurl.com/mr3t2ny5) '''

courses = ['History', 'Math', 'Physics', 'English', 'CompSci']

# Alternate constructor
courses2 = list('History', 'Math', 'Physics', 'English', 'CompSci')
print(courses2)


# # The print and len functions can be used with lists
# print(f'There are {len(courses)} elements in the list.')

# # Access by positive or negative index
# print(f'Courses: {courses}')
# print(f'courses[0] = {courses[0]}')
# print(f'courses[1] = {courses[1]}')
# print(f'courses[-2] = {courses[-2]}')

# # Assignment
# courses2 = courses
# print(f'Course List 1 (ID: {id(courses)}): {courses}')
# print(f'Course List 2 (ID: {id(courses2)}): {courses2}')

# # Both lists change when one changes
# print(f'Changed courses 2[0]')
# courses2[0] = "Engineering"
# print(f'Course List 1 (ID: {id(courses)}): {courses}')
# print(f'Course List 2 (ID: {id(courses2)}): {courses2}')

# # Operators and statements
# print(f'Physics in courses: {"Physics" in courses}')
# print(f'Music in courses: {"Music" in courses}')

# # Iterating over a list
# i = 1
# for course in courses:
#     print(f'Course #{i}: {course}')
#     i+=1

# for index, course in enumerate(courses):
#     print(f'Course #{index}: {course}')

# # Using a slicer (slicing) to retrieve a subset of the list
# print('\nSlicers...')
# print(f'courses[1:3] is:  {courses[1:3]}')
# print(f'courses[3:] is {courses[3:]}')
# print(f'courses[:3] is {courses[:3]}')

# # Using the (non-destructive) sorted function
# print(f'The sorted list is: {sorted(courses)}')
# print(f'The original list is: {courses}')

# # Using min and max on lists
# num_list = [0, 1, -2, 15, 100, -25, -77]
# print(f'min of {num_list} is {min(num_list)}')
# print(f'max of {num_list} is {max(num_list)}')

# # Useful methods on the list object
# new_list = ['a', 'b', 'c']
# print(f'\nStarting list: {new_list}')

# # append
# new_list.append(6)
# print(f'.append(6) yields {new_list}')

# # Appending a list adds the whole list as a single element
# new_list.append([6, 7, 8])
# print(f'.append([6,7,8]) yields {new_list}')

# # pop
# element = new_list.pop()
# print(f'.pop returns the last element of the list: {element}')
# print(f'\t and removes it: {new_list}\n')

# # extend
# new_list.extend([9, 10, 11])
# print(f'.extend appends items in the list individually: {new_list}')

# # insert
# new_list.insert(3, 'cat')
# print(f'.insert(3, "cat") yields: {new_list}')

# # remove
# new_list.remove(6)
# print(f'.remove(6) yields: {new_list}')

# # index
# print(f'.index("b") = {new_list.index("b")}')

# # Confirm an exception is raised if the value is not in the list
# try:
#     index = new_list.index('x')
# except ValueError as e:
#     print("Confirmed the value 'x' is not in the list")

# # String methods
# # Combine a list into a string with a specified separator
# msg = ",".join(['cat', 'dog', 'fish', 'monkey']) # List must contain strings
# print(f"{msg}")

# # Split a string on the specified separator
# print(msg.split(','))

# # Creating a list with list(<object>)
# list_from_string = list('amazing cats')
# print(list_from_string)

# list_from_dictionary = list({'hat':'fedora', 'glasses':'monacle'})
# print(list_from_dictionary)