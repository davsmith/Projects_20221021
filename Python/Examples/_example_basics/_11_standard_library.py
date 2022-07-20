''' The Standard Library (https://tinyurl.com/ypsfs42f) '''
import os

# The Standard Library is a set of modules included with the Python installation
# Each module provides functionality in an area such as math, os, or random
#

#
# OS
#

# Determine the current working directory
print(f'Current directory is {os.getcwd()}')

# Change the current working directory
os.chdir('c:\\temp')

# Get the contents of the cwd or specified path
contents = os.listdir('c:\\temp')
print(contents)

# List all environment variables
for variable in os.environ:
    value = os.environ.get(variable,'value')
    print('{} = {}'.format(variable, value))

# Get the value of an environment variable
env_onedrive = os.environ.get('OneDrive')
print(f'OneDrive = {env_onedrive}')

#  Set environment variables
os.environ['PYGAME_HIDE_SUPPORT_PROMPT'] = '1'

