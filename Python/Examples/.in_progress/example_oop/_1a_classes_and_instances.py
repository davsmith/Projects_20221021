''' Classes and Instances (https://tinyurl.com/5fu5xytn) '''

# Defining a simple class
class MyClass:
    pass

class MyClassWithInitAndArguments:
    def __init__(self, arg1, arg2):
        print(f'self: {self}')
        print(f'arg1: {arg1}')
        print(f'arg2: {arg2}')

class MyClassWithMethods:
    def print_full_name(self, first_name, last_name):
        print(f'Hello {first_name} {last_name} (from {self})')


# Example 1: Instantiating a simple class
obj1 = MyClass()
print(type(obj1))

# Example 2: Demonstrate __init__ and arguments
# Two arguments specified, but three are passed to the method
# (i.e. the self argument is added by the interpreter)
obj2 = MyClassWithInitAndArguments("Dave", "Smith")

# Example 3: Calling a method
obj3 = MyClassWithMethods()
obj3.print_full_name("Bob", "Treeflower")
MyClassWithMethods.print_full_name("<self>", "Harold", "Wannati")