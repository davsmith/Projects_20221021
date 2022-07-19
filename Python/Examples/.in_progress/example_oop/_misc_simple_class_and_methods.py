'''
 Information and examples of classes in Python
'''


class Primitive1:
    ''' Primitive class definition with a constructor and two public methods
        Per PyLint classes with fewer than 2 public methods should likely be a
        different data type (likely either dict or dataclass) (too-few-public-methods)
    '''

    # - The __init__ method is the Python version of a constructor
    # - The initial method of __init__ and each method should typically be 'self' which
    #   is a pointer to the object itself.
    # - Instance variables allow public access
    #

    def __init__(self):
        self.greeting = "Hello"
        self.name = None

    def say_greeting(self):
        ''' Prints out the greeting text '''
        if self.name is None:
            print(self.greeting)
        else:
            print(f"{self.greeting}, {self.name}")

    def set_name(self, name):
        ''' Sets the instance variable for the name to greet '''
        self.name = name


def main():
    ''' The main function '''
    object1 = Primitive1()
    object1.set_name("Bob")
    object1.say_greeting()
    object1.greeting = "What's up"
    object1.say_greeting()


if __name__ == '__main__':
    main()
