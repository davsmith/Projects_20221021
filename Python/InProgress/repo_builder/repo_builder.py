''' Library to build a series of files, commits, and branches for a git repo '''

# Created 8/12/2022 by Dave Smith
#


import os
from tempfile import gettempdir

def get_folder_path(folder=None):
    if folder == None:
        folder = gettempdir()

    return folder

''' Create a set of files '''
def create_files(count, prefix=None, parent_folder=None):
    if prefix == None:
        prefix = "tmp_file"
    for i in range(1, count+1):
        filename = f"{get_folder_path(parent_folder)}\\{prefix}{i}.txt"
        command = f"echo This is file {i} > {filename}"
        res = os.system(command)


def create_folder(directory, parent_dir=None):

    # Parent path to the directory
    parent = get_folder_path(parent_dir)

    # Full path
    path = os.path.join(parent, directory)
    os.makedirs(path, exist_ok=True)

    return path


''' Initializes a repo under the current or specified folder '''
def create_repo(repo_name, parent_folder=None):
    path = create_folder(repo_name, parent_folder)
    os.chdir(path)
    
    command = "git init"
    result = os.system(command)
    return path

s = r'lang\tver\nPython\t3'
print(s)
path = create_repo("repo1", "c:\\temp\\")
create_files(count=10, parent_folder=path)  

