''' Instance, class and private variables (https://tinyurl.com/yeyparnv) '''

class MyClass:
    def __init__(self, first_name, last_name):
        self.first_name = first_name
        self.last_name = last_name

    def print_greeting(self):
        print(f'Hello {self.prefix} {self.first_name} {self.last_name}')

class MyClassWithClassVariables:
    greeting = 'Hello'

    def __init__(self, first_name, last_name):
        self.first_name = first_name
        self.last_name = last_name

    def print_greeting_scope_walk(self):
        print(f'{self.greeting} {self.prefix} {self.first_name} {self.last_name}')

    def print_greeting_explicit_class_variable(self):
        print(f'{MyClassWithClassVariables.greeting} {self.prefix} {self.first_name} {self.last_name}')

class DemonstratePrivateVariables:
    def __init__(self, first_name, last_name, salary):
        self.first = first_name
        self._last = last_name
        self.__salary = salary

    def print_full_name(self):
        print(f'{self._last}, {self.first}')


# Example 1: Create an object and assign local variables using two manners
obj1 = MyClass('Dave', 'Smith')
obj1.prefix = 'Mr.'
obj1.print_greeting()
print(f'Instance variables:\n{obj1.__dict__}')

# Example 2a: Define and reference a class variable
print('\nExample 2a: Interpreter looks for instance variables before class variables')

# Reference the class variable via checking instance first, then class
obj2 = MyClassWithClassVariables('Dave', 'Smith')
obj2.prefix = 'Mr.'
obj2.print_greeting_scope_walk()

# The interpreter will prefer the instance variable once it's created
obj2.greeting = 'Good day'
obj2.print_greeting_scope_walk()

print(f'Instance variables:\n{obj2.__dict__}')
print(f'Class variables:\n{MyClassWithClassVariables.__dict__}')

# Example 2b: Explicitly use the class variable
print('\nExample 2b: Interpreter uses class variable regardless of instance variables')
obj3 = MyClassWithClassVariables('Dave', 'Smith')
obj3.prefix = 'Mr.'
obj3.print_greeting_explicit_class_variable()

# The interpreter will continue to use the class variable over the instance variable
obj3.greeting = 'Good day'
obj3.print_greeting_explicit_class_variable()

# Example 3: Private variables
# Though they can be referenced directly, prefixing a variable with
# _ indicates the variable is considered private
#
# Prefixing a variable with __ prompts the interpreter to 'mangle' the
# variable name so it can't be referenced accidentally
obj4 = DemonstratePrivateVariables("Dave", "Smith", 20000)
print(f'Instance variables:\n{obj4.__dict__}')