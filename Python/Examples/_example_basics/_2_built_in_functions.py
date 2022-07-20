''' Built-in Functions (https://tinyurl.com/ym5hktjp) '''

'''
There are several dozen functions and variables built in to Python, meaning they can be called without importing
any modules.

Below are examples of some of the more prevalent.
'''

from example_formatter import ExampleFormatter
ex = ExampleFormatter()


n = 4
f = 2.0
neg = -7
str1 = 'Hello world!'

def simple_function(arg1, arg2):
    ''' A simple function for demonstration '''
    return arg1+arg2

ex.new_example('Help')
print(dir(str1))
print(dir(n))
print(dir(f))
print(dir(simple_function))
help(simple_function)
# help(str)
help(str.lower)
# print(dir())
ex.end_example()

ex.new_example('Math')
print(abs(neg))
print(len('Hello there!'))
print(max(-5,5,1,-2,3,-7,6))
print(min(-5,5,1,-2,3,-7,6))
print(pow(2,8))
print(round(1.5))
print(round(2.675,2))  # Rounds to 2.67 instead of 2.68 due to Python glitch.  See Python docs.
print(list(range(10,100,10)))
ex.end_example()

ex.new_example('Types')
print(id(str1))
print(float("1.234"))
print(int("4"))
print(type(str1))
print(str(1.234))
ex.end_example()

ex.new_example('Help')
# print(getattr())
print(dir(str1))
print(repr(simple_function))
print(sorted([-1,1,6,-7,8,4], reverse=True))
print(reversed([-1,1,6,-7,8,4]))
ex.end_example()
