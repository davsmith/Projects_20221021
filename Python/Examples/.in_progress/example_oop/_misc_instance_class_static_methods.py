"""
Examples of Instance, Class, and Static Methods from Real Python (http://bit.ly/2WPnsUH)
"""
import math


class MyClass:
    """ Basic class with three types of methods """

    def method(self):
        """ Instance method """
        return f'instance method called on object {self} for class {self.__class__}'

    @classmethod
    def classmethod(cls):
        """ Class method """
        return 'class method called', cls

    @staticmethod
    def staticmethod():
        """ Static method """
        return 'static method called'


class Pizza:
    """ Helper methods for delicious pizza """

    def __init__(self, radius, ingredients):
        self.radius = radius
        self.ingredients = ingredients
        print(f"Instantiated a pizza with {self.ingredients}")

    def __repr__(self):
        return f'Pizza({self.radius!r}, {self.ingredients!r})'

    def area(self):
        """ Calculate the area of the pizza based on the radius """
        return self.circle_area(self.radius)

    @classmethod
    def margherita(cls):
        """ Special case of the pizza class """
        return cls(4, ['mozzarella', 'tomatoes'])

    @classmethod
    def prosciutto(cls):
        """ Special case of the pizza class """
        return cls(4, ['mozzarella', 'tomatoes', 'ham'])

    @staticmethod
    def circle_area(radius):
        """ Static method to return the area of a circle """
        return radius ** 2 * math.pi


def main():
    """ Main function """
    obj = MyClass()
    print("--- Instance methods ---")

    # Call an instance method using 'dot notation'
    print(obj.method())

    # Call an instance method from the class, passing in the object manually
    # This seems like an atypical method of calling the method
    print(MyClass.method(obj))

    print("")

    print("--- Class methods ---")
    # Call the class method directly on the class
    print(MyClass.classmethod())

    # A class method can be called from the instance object as well
    print(obj.classmethod())

    print("")

    print("--- Static methods ---")
    # Call a static method on an object instance
    print(obj.staticmethod())

    # Call a static method on the class itself
    print(MyClass.staticmethod())

    print("")

    print("--- Pizza class ---")
    # Create an instance of the class by insantiating it
    pizza1 = Pizza(8, ['cheese', 'tomatoes'])

    print(f"Order up with {pizza1}")

    # Create special pizzas with a class factory
    pizza2 = Pizza.margherita()
    pizza3 = Pizza.prosciutto()
    print(f"Order up with {pizza2} and {pizza3}")

    # Demonstrate calling a static method
    print(Pizza.circle_area(4))


if __name__ == "__main__":
    main()
