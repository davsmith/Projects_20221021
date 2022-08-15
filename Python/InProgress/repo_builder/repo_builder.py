''' Library to build a series of files, commits, and branches for a git repo '''

# Created 8/12/2022 by Dave Smith
#


from operator import truediv
import os
import shutil
import glob
import random
import datetime
import stat
  
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
    try:
        shutil.rmtree(git_path)
    except FileNotFoundError:
        print(f"Couldn't find {repo_path}")

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
def get_file_list(folder_path, file_spec=None, limit=0, start_with=0, randomize=False):
    full_path = Path(folder_path, file_spec)
    full_file_list = glob.glob(str(full_path))
    if limit == 0:
            limit = len(full_file_list)
            print(limit)
    num_samples = min(limit, len(full_file_list))

    if randomize == True:
        samples = random.sample(full_file_list, num_samples)
    else:
        samples = full_file_list[start_with:start_with+num_samples]

    return(samples)

def change_files(file_list, message=None):
    if message == None:
        current_time = datetime.datetime.now()
        message = f"Updated file at {current_time}"

    for file in file_list:
        command = f"echo {message} >> {file}"
        os.system(command)

def switch_branch(repo_path, branch_name, create=True):
    options = ""

    os.chdir(repo_path)
    if create == True:
        # options = f"{options} -b"
        # Attempt to create the branch
        # This will fail if the branch already exists
        command = f'git branch {branch_name}'
        result = os.system(command)
        print(f"Attempted to create branch '{branch_name}' (Result:{result})")
    
    command = f'git checkout {options} {branch_name}'
    result = os.system(command)
    print(f"Attempted to switch to branch '{branch_name}' (Result: {result})")

''' Creates files and adds them to the repo '''
def populate_repo(repo_path, num_files=1, msg=None):
    num_files = max(num_files, 1)

    if msg == None:
        msg = 'C1'

    create_files(count=num_files, folder_path=repo_path)
    commit_files(repo_path, '*.txt', msg)

def add_commits(repo_path, num_commits, commit_index=1, num_files=1, allow_conflicts=False, branch=None):
    os.chdir(Path(repo_path))

    if branch != None:
        switch_branch(repo_path, branch, create=False)

    next_commit = commit_index

    # BUGBUG: This is a hokey algorithm.  Ideally if allow_conflicts is False, the
    # file list would exclude any files which have already been changed.
    if allow_conflicts:
        file_list = get_file_list(repo_path, "*.txt", limit=num_files, start_with=0)
    else:
        # If conflicts are not allowed, only a single random file and hope for the best
        num_files = 1
        file_list = get_file_list(repo_path, "*.txt", limit=num_files, randomize=True)
        
    for i in range(1, num_commits+1):
        change_files(file_list)
        commit_files(repo_path, '*.txt', f"C{next_commit}")
        next_commit += 1

# Change the mode of read only files
def rmtree_callback_removeReadOnly(func, path, excinfo):
    if isinstance(excinfo[1], FileNotFoundError):
        print("File not found.  Ignored.")
    else:
        print(f"Setting write access for {path} ")
        os.chmod(path, stat.S_IWRITE)
        func(path)

def danger_delete_folder(folder_name=None):
    if folder_name == None:
        folder_path = Path("c:/temp/test1")
    else:
        folder_path = Path(folder_name)

    shutil.rmtree(folder_path, onerror=rmtree_callback_removeReadOnly)


#
# Main
#
if __name__ == '__main__':
    parent_folder = "c:/temp"
    repo_name = 'test1'

    commit_count = 0

    danger_delete_folder(Path(parent_folder, repo_name))

    repo_path = create_repo(repo_name, parent_folder)
    populate_repo(repo_path, num_files=5)
    next_commit = 2

    switch_branch(repo_path, 'new_feature')
    num_commits = 3
    add_commits(repo_path, num_commits=num_commits, commit_index=next_commit, allow_conflicts=True)
    next_commit += num_commits

    switch_branch(repo_path, 'master')
    num_commits = 2
    add_commits(repo_path, num_commits=num_commits, commit_index=next_commit, allow_conflicts=True)
    next_commit += num_commits

    # remove_repo(repo_path)


