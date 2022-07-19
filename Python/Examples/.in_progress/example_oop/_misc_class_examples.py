"""
    Examples of defining and using classes in Python from Python Crash Course for Beginners
    Link: https://www.youtube.com/watch?v=JJmcL1N2KQs&t=1733s (Traversy Media)
"""


class User:
    """
        Base class with basic information to be inherited
    """
    # Constructor

    def __init__(self, name, email, age):
        self.name = name
        self.email = email
        self.age = age

        # Adding Encapsulation of variables
        #    Encapsulation is the concept of making the variables non-accessible or
        #    accessible upto some extent from the child classes
        #    Encapsulated variables are declared with '_' in the constructor.
        self._private = 1000

    def greeting(self):
        """ Demonstrates use of an f-string and access to instance variables """
        return f'My name is {self.name} and I am {self.age}'

    def has_birthday(self):
        """ Increments the age instance variable """
        self.age += 1

    def print_encap(self):
        """ function for encapulated (private) variable """
        print(self._private)


class Customer(User):
    """ Extend the User base class """

    def __init__(self, name, email, age):
        """
            Calls the constructor on the parent class to assign instance variables
            Then adds a balance property
        """
        #    inheriting all methods.
        User.__init__(self, name, email, age)
        self.name = name
        self.email = email
        self.age = age
        self.balance = 0

    def set_balance(self, balance):
        """ Sets the users' balance """
        self.balance = balance

    def greeting(self):
        """ Greets the customer """
        return f'My name is {self.name} and I am {self.age} and my balance is {self.balance}'


#  Init user object
brad = User('Brad Traversy', 'brad@gmail.com', 37)
# Init customer object
janet = Customer('Janet Johnson', 'janet@yahoo.com', 25)

janet.set_balance(500)
print(janet.greeting())

brad.has_birthday()
print(brad.greeting())

# Encapsulation -->
brad.print_encap()
brad._private = 800  # Changing for brad
brad.print_encap()

# Method inherited from parent
# Changing the variable for brad doesn't affect janets variable --> Encapsulation
janet.print_encap()
janet._private = 600
janet.print_encap()

# Similary changing janet's doesn't affect brad's variable.
brad.print_encap()
