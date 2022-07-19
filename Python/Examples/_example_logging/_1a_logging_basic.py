''' Logging - Basic (https://tinyurl.com/d7jb5mdy) '''

"""
    - Logging functionality is included in the Python Standard Library as the logging module
	- The logger can be configured to work in one of two modes:
			1. A single instance with a single set of settings and one log file across all modules (ref)
			2. Multiple instances of the logger used to create separate logs for each module (ref)
		
	- Common logging categories are Debug, Info, Warning, Error, Critical (web)
			DEBUG	Diagnostic information useful for debugging
			INFO	General information about program execution results
			WARNING	Something unexpected which may cause an error, or an approaching problem (e.g. low disk space)
			ERROR	Unable to perform a specific operation due to a problem
			CRITICAL	Serious error.  Program may not be able to continue.
			
	- Use the .debug, .info, .warning, .error, and .critical methods on the logging object or a logger instance
	- Use .exception to include the call stack in the logging text

    This module demonstrates the single instance of a logger (mode 1)
 """

import logging

# The default logging level is logging.WARNING and logs to the console
#
# Use .basicConfig method to change the default logging options such as:
#   level - changes the logging level for the module (debug, info, warning, error, critical)
#   filename - changes log destination of log messages from console to the specified file
#   format - changes the information included in the log string (time, level, etc.)
#

logging.basicConfig(
    filename="test.log",
    level=logging.DEBUG,
    format="%(funcName)s:%(asctime)s> %(message)s",
    datefmt="%m/%d/%Y %I:%M:%S %p",
    filemode="w"
)


def add(x, y):
    """Add Function"""
    logging.debug("Entered the add method")
    return x + y


def subtract(x, y):
    """Subtract Function"""
    return x - y


def multiply(x, y):
    """Multiply Function"""
    return x * y


def divide(x, y):
    """Divide Function"""
    return x / y


num_1 = 10
num_2 = 5

add_result = add(num_1, num_2)
# print("Add: {} + {} = {}".format(num_1, num_2, add_result))
logging.debug("Add: {} + {} = {}".format(num_1, num_2, add_result))

# Example log messages
logging.debug("This is a debug message")
logging.info("This is an info message")
logging.warning("This is an warning message")
logging.error("This is an error message")
logging.critical("This is a critical message")
