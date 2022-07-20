''' Loops and Iterations (https://tinyurl.com/temf6npy) '''

#
# Looping with for and while #
#

grocery_list = {'cheese', 'lettuce', 'sushi', 'cabbage', 'cereal', 'yogurt', 'tooth paste'}
print(f'Grocery list: {grocery_list}')

# Use for to loop through elements of a list (for <var> in <object>:)
print('\n*** Iterating through a loop with for ***')
for grocery in grocery_list:
    print(f'Item {grocery}... beep')

# Break terminates the loop
print('\n*** Breaking out of a loop ***')
count = 1
for grocery in grocery_list:
    print(f'Item {grocery}... beep')
    count += 1
    if count > 5:
        print(f'Sorry.  Five items or less.')
        break

# Continue terminates the iteration but continues the loop
print('\n*** Continuing a loop ***')
count = 1
for grocery in grocery_list:
    print(f'Item {grocery}... beep')
    count += 1
    if grocery == 'cabbage' :
        print(f'Recall on cabbage. Skip putting it in the bag.')
        continue
    print(f'Put {grocery} in the bag.')

# Use a range object to iterate through a numeric sequence
# The range object is inclusive of start, but exclusive of end
print('\n*** Counting from 1 to 10 ***')
for i in range(1,11):
    print(f'Iteration {i}')

# Step by 3s
print('\n*** Counting by 3s ***')
for i in range(3,40, 3):
    print(f'Iteration {i}')

# Loops can be nested
print('\n*** Nesting two loops ***')
num_rows = 5
num_columns = 3
for x in range(0, num_columns):
    for y in range(0, num_rows):
        print(f'({x}, {y})')

# While loops iterate while a condition is true
print('\n*** Iterate while a condition is true ***')
num_candy = 0
max_candy = 5

while num_candy < max_candy:
    print(f'Good news.  You may have more candy!')
    num_candy += 1

# Use while true for an infinite loop
print('\n*** Entering an infinite loop with while true.  Use ctrl-c to break out. ***')
try:
    while True:
        pass
except KeyboardInterrupt:
    print("Great!  You've exited the loop.")