''' Class and Static methods (https://tinyurl.com/5cv7ahmr) '''

class ShowClassMethods:
    
    _greeting = 'Hello'

    @classmethod
    def set_class_variables(cls, greeting):
        cls._greeting = greeting

    @classmethod
    def alternate_constructor(cls, full_name):
        last_name, first_name = full_name.split('_')
        return cls(first_name, last_name)

    def __init__(self, first_name, last_name):
        self.first_name = first_name
        self.last_name = last_name

    def print_greeting(self):
        print(f'{ShowClassMethods._greeting} {self.first_name} {self.last_name}')


class QuickMath:
    @staticmethod
    def add(x, y):
        print(f'Adding {x} and {y}')
        return(x+y)

    @staticmethod
    def subtract(x, y):
        print(f'Subtracting {y} from {x}')
        return(x-y)

    @staticmethod
    def multiply(x, y):
        print(f'Multiplying {x} and {y}')
        return(x*y)

    @staticmethod
    def divide(x, y):
        print(f'Dividing {x} by {y}')
        return(x/y)


# Example 1a: Define and reference a class method to access class variables
print('\nExample 1a: Class methods are called with <class>.<method>')

# Create three objects and show that they all have the same value for greeting
obj1 = ShowClassMethods('Will', 'Riker')
obj2 = ShowClassMethods('Wesley', 'Crusher')
obj3 = ShowClassMethods('Beverly', 'Crusher')

obj1.print_greeting()
obj2.print_greeting()
obj3.print_greeting()

# Change the class variable (greeting) with a class method
ShowClassMethods.set_class_variables(greeting='Good day')

# The value was changed for all instances of the class
obj1.print_greeting()
obj2.print_greeting()
obj3.print_greeting()

# Example 2: Instantiate an object with an alternate constructor (class method)
obj4 = ShowClassMethods.alternate_constructor('Picard_Jean Luc')
obj4.print_greeting()

# Example 3: Use a static method without having to create an instance
print(QuickMath.add(4,8))
print(QuickMath.multiply(9,8))