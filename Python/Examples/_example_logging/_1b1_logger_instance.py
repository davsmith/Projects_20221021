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

    This module demonstrates the instance of a logger (mode 2)
"""

import logging
import _1b2_employee
import _1b3_car

# logging.lastResort = None
# Create and configure an instance of a logger object (from the logging object)
logger = logging.getLogger(__name__)

# Set the minimum log level for a message to be passed to any of the handlers
logger.setLevel(logging.DEBUG)

# Create a format object specifying how log messages are displayed
#  and optionally the date format
formatter = logging.Formatter("%(asctime)s:%(name)s: (%(levelname)s) %(message)s", datefmt="%m/%d/%Y %I:%M:%S %p")

# Create and configure a file handler for logging messages to a file
file_handler = logging.FileHandler('{}.log'.format(__name__), mode='w')
file_handler.setLevel(logging.DEBUG)
file_handler.setFormatter(formatter)

# Create and configure a stream handler for logging to the console
stream_handler = logging.StreamHandler()
stream_handler.setLevel(logging.CRITICAL)
stream_handler.setFormatter(formatter)

# Register the handlers with the instance of the logger object
logger.addHandler(file_handler)
logger.addHandler(stream_handler)

# Log messages using the logger object (not the logging object)
print(f'The effective logging level is {logger.getEffectiveLevel()}')
logger.debug("This is a debug message")
logger.info("This is an info message")
logger.warning("This is a warning message")
logger.error("This is an error message")
logger.critical("This is a critical message")