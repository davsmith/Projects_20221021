''' Logging - Support Module (Employee Class) (https://tinyurl.com/d7jb5mdy) '''
import logging

# Create and configure an instance of a logger object (from the logging object)
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(asctime)s:%(name)s: (%(levelname)s) %(message)s", datefmt="%m/%d/%Y %I:%M:%S %p")

file_handler = logging.FileHandler('{}.log'.format(__name__), mode='w')
file_handler.setLevel(logging.DEBUG)
file_handler.setFormatter(formatter)

# Register the handlers with the instance of the logger object
logger.addHandler(file_handler)

logger.debug('Created instance log for employee module')

class Employee:
    """A sample Employee class"""

    def __init__(self, first, last):
        self.first = first
        self.last = last

        logger.info("Created Employee: {} - {}".format(self.fullname, self.email))

    @property
    def email(self):
        """Set email property"""
        return "{}.{}@email.com".format(self.first, self.last)

    @property
    def fullname(self):
        """Set full name property"""
        return "{} {}".format(self.first, self.last)


emp_1 = Employee("John", "Smith")
emp_2 = Employee("Corey", "Schafer")
emp_3 = Employee("Jane", "Doe")
