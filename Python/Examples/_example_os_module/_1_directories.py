''' Working with Directories (https://tinyurl.com/) '''

# Modified from https://www.geeksforgeeks.org/python-os-makedirs-method/

import os
from pathlib import Path
import shutil
import stat

'''
#
# mkdirs
#
# Creates the specified directory and all of its parent nodes as required
# No changes are made if the directory already exists
#
# The mode parameter is OS dependent and may have no effect
# If the exists_ok parameter is false (default) and the folder exists a FileExistsError is raised
#
# The function accepts many formats for the path including /, \ and mixed
#


# Name of the directory to create
directory = "tmp_os_module"

# Parent path to the directory
parent_dir = "c:\\temp\\examples\\GeeksForGeeks"

# Full path
path = os.path.join(parent_dir, directory)

#
# Create the directory
#
os.makedirs(path, mode=0o777, exist_ok=True)
print("Directory '%s' created" %directory)

# Create the directory again with exist_ok = False and catch the exception
try:
    os.makedirs(path)
except FileExistsError as e:
    print(f"Directory '{directory}' already exists.")
else:
    print(f"Created directory '{directory}'.")


# Create a directory using forward slashes, and change the mode
# Leaf directory
directory = "c"

# Parent Directories
parent_dir = "C:/Temp/Examples/Documents/GeeksforGeeks/a/b"

# mode
mode = 0o666

path = os.path.join(parent_dir, directory)
os.makedirs(path, mode, exist_ok=True)
print("Directory '%s' created" %directory)

#
# Listing the files in a directory
#
path = "c:/temp/repo1"
file_list = os.listdir(path)
print(file_list)

# Print the files with .txt file extension
for file in file_list:
    if file.endswith('.txt'):
        print(file)

# Print the absolute path and stats for each file
for file in file_list:
    full_file_path = Path(path,file)
    print(full_file_path)
    print(os.stat(full_file_path))
'''
#
# Deleting a directory
#

# Recursively deletes directories including files, subdirectories (including .git)
# Raises FileNotFoundError if the directory does not exist
#
# ignore_errors = True suppresses errors
# onerror = a callback/exception handler when errors occur
#
# Reference:
# https://tinyurl.com/yc5kxatz

# Change the mode of read only files
def removeReadOnly(func, path, excinfo):
    print(f"Setting write access for {path} ")
    os.chmod(path, stat.S_IWRITE)
    func(path)

dir_to_delete = Path("c:/temp/test1")
# shutil.rmtree(dir_to_delete, ignore_errors=False)
shutil.rmtree(dir_to_delete, onerror=removeReadOnly)

# Would normally fail because the directory has already been deleted
shutil.rmtree(dir_to_delete, ignore_errors=True)

# Catch the exception and report an error message
try:
    shutil.rmtree(dir_to_delete, ignore_errors=False)
except FileNotFoundError as e:
    print(f"Could not find file '{dir_to_delete}'")





