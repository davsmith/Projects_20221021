''' Working with Directories (https://tinyurl.com/) '''

# Modified from https://www.geeksforgeeks.org/python-os-makedirs-method/

import os

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