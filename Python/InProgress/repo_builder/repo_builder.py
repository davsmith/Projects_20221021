''' Library to build a series of files, commits, and branches for a git repo '''

# Created 8/12/2022 by Dave Smith
#


from operator import truediv
import os
import shutil
import glob
import random
import datetime;
  
from tempfile import gettempdir
from pathlib import Path


def get_folder_path(folder=None):
    if folder == None:
        folder = gettempdir()

    return Path(folder)

''' Create a folder '''
def create_folder(directory, parent_folder=None):

    # Parent path to the directory
    parent = get_folder_path(parent_folder)

    # Full path
    folder_path = os.path.join(parent, directory)
    os.makedirs(folder_path, exist_ok=True)

    return folder_path

''' Create a set of files '''
def create_files(count, prefix=None, folder_path=None):
    if prefix == None:
        prefix = "tmp_file"
    for i in range(1, count+1):
        filename = Path(get_folder_path(folder_path),f"{prefix}{i}.txt")
        command = f"echo This is file {i} > {filename}"
        result = os.system(command)

''' Initializes a repo under the current or specified folder '''
def create_repo(repo_name, parent_folder=None):
    path = create_folder(repo_name, parent_folder)
    os.chdir(path)
    
    command = "git init"
    result = os.system(command)
    return path

def remove_repo(repo_path):
    git_path = Path(repo_path, '.git')
    shutil.rmtree(git_path, ignore_errors=True)

def commit_files(repo_path, file_specifier=None, comment=None):
    os.chdir(repo_path)

    if file_specifier == None:
        file_specifier = "*.txt"

    if comment == None:
        comment = 'Automatically committing changes'

    command = f"git add {file_specifier} "
    result = os.system(command)

    command = f'git commit -m "{comment}"'
    print(f"Command: {command}")
    result = os.system(command)

''' Generates a list containing a subset of the files in a specified folder '''
def get_file_list(folder_path, file_spec=None, limit=0, randomize=False):
    full_path = Path(folder_path, file_spec)
    full_file_list = glob.glob(str(full_path))
    if limit == 0:
            limit = len(full_file_list)
            print(limit)
    num_samples = min(limit, len(full_file_list))

    if randomize == True:
        samples = random.sample(full_file_list, num_samples)
    else:
        samples = full_file_list[0:num_samples]

    return(samples)

def change_files(file_list, message=None):
    if message == None:
        current_time = datetime.datetime.now()
        message = f"Updated file at {current_time}"

    for file in file_list:
        command = f"echo {message} >> {file}"
        os.system(command)
        
parent_folder = "c:/temp"
repo_name = 'repo2'

repo_path = create_repo(repo_name, parent_folder)

create_files(count=10, folder_path=repo_path)
commit_files(repo_path, '*.txt')
file_list = get_file_list(repo_path, "*.txt", 4, True)

for commit_index in range(1,16):
    change_files(file_list)
    commit_files(repo_path, '*.txt')

# remove_repo(repo_path)


