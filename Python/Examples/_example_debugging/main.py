''' Debugging in VS Code (https://tinyurl.com/5dfahn4t) '''

"""
    This is a simple loop with some variables to demonstrate stepping
    through and evaluating code in VS Code

    Created: 6/29/2022
    Updated: 6/29/2022
"""

running = True
counter = 1

# print(3/0)

while running:
    print("Hello world")
    print("Second line")
    print("Random text")
    counter += 1
    if (counter == 30):
        running = False
    print("End of the loop")
print("End of the app")

def set_globals():
    global whatsit

    whatsit = 'A global in a function'
    local_val1 = 1
    local_val2 = 'I am a string'
    local_val3 = ['element1', 'element2']

set_globals()