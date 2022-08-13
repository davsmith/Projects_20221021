''' Examples of working with file paths '''
#
# Reference:
#   https://python.plainenglish.io/manipulating-file-paths-with-python-72a76952b832
#   https://docs.python.org/3/library/pathlib.html
#

from pathlib import Path
import os

#
# Directories and file locations
#

# Current working directory (cwd)
print("Current working directory: ", os.getcwd())

# User/home directory
print("User/home path: ", Path.home())

# File location
print("File location: ", __file__)

# Path to the currently running script
print("File path: ", Path(__file__).absolute().parent)

#
# Building paths
#

# Using the forward slash operator with a Path object
file_path = Path(__file__).absolute().parent
full_filename = file_path / 'mujiber.txt'
print("Full file: ", full_filename)

# Building a relative path
path = Path('foo', 'bar', 'bat', 'foo.txt')
print(path)

# Building an absolute path
base_folder = r'c:\temp'
full_path = Path(base_folder, 'abc', 'def', 'ghi')
print(full_path)

# Passing a Path object as an argument
base_path = Path(base_folder)
full_path2 = Path(base_path, 'abc', 'def', 'ghi')
print(full_path2)