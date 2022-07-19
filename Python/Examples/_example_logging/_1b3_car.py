''' Logging - Support Module (Car Class) (https://tinyurl.com/d7jb5mdy) '''

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


class Car:
    """A sample Car class"""

    def __init__(self, make, model, year):
        self.make = make
        self.model = model
        self.year = year

        logger.info("Created Car: {}, {}, {}".format(self.year, self.make, self.model))

    # @property
    # def email(self):
    #     """Set email property"""
    #     return "{}.{}@email.com".format(self.first, self.last)

    # @property
    # def fullname(self):
    #     """Set full name property"""
    #     return "{} {}".format(self.first, self.last)


car_1 = Car("Toyota", "Tacoma", 2010)
car_2 = Car("Honda", "Pilot", 2018)
car_3 = Car("Nissan", "Leaf", 2020)