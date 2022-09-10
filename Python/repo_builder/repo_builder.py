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
import subprocess
  
from tempfile import gettempdir
from pathlib import Path

class FileBuilder:
    def __init__(self, parent_path, prefix=None, file_type=None):
        
        if prefix == None:
            prefix = 'tmp_'
        
        if file_type == None:
            file_type = '.txt'

        self.prefix = Path(prefix)
        self.parent_path = Path(parent_path)
        self.file_type = file_type
        self.index = 1

    ''' Make a change to a file so it shows as "dirty" '''
    def touch_files(self, count, create=True):
        prefix = self.prefix
        folder_path = self.parent_path

        if create == True:
            start = self.index
        else:
            start = 1
            
        for i in range(start, start+count):
            filename = Path(folder_path,f"{prefix}{i}.txt")
            command = f"echo This is file {i} >> {filename}"
            result = os.system(command)
            self.index += 1

    ''' Create a Path object from a string '''
    @staticmethod
    def get_folder_path(folder=None):
        if folder == None:
            folder = gettempdir()

        return Path(folder)

    ''' Create a folder from the folder name and parent path '''
    @staticmethod
    def create_folder(directory, parent_folder=None):

        # Parent path to the directory
        parent = FileBuilder.get_folder_path(parent_folder)

        # Full path
        folder_path = os.path.join(parent, directory)
        os.makedirs(folder_path, exist_ok=True)

        return folder_path

    ''' Delete an entire folder and subfolders '''
    @staticmethod
    def danger_delete_folder(folder_path):
        shutil.rmtree(folder_path, onerror=FileBuilder.rmtree_callback_removeReadOnly)

    ''' Change the mode of read only files '''
    @staticmethod
    def rmtree_callback_removeReadOnly(func, path, excinfo):
        if isinstance(excinfo[1], FileNotFoundError):
            print("File not found.  Ignored.")
        else:
            print(f"Setting write access for {path} ")
            os.chmod(path, stat.S_IWRITE)
            func(path)

class Repo:
    def __init__(self, repo_name, parent_folder=None):
        self.repo_name = repo_name
        self.parent_folder = parent_folder
        self.full_path = Path(self.parent_folder, self.repo_name)
        self.commit_count = 0
        self.file_builder = FileBuilder(self.full_path, 'tmp_')

    ''' Initialize a repo under the current or specified folder '''
    def create_repo(self):
        # Delete the existing repo (including files)
        FileBuilder.danger_delete_folder(self.full_path)
        FileBuilder.create_folder(self.repo_name, self.parent_folder)
        os.chdir(self.full_path)
        
        command = "git init"
        result = os.system(command)

    ''' Delete a repo by deleting the .git subfolder '''
    def remove_repo(self):
        git_path = Path(self.full_path, '.git')
        try:
            shutil.rmtree(git_path)
        except FileNotFoundError:
            print(f"Couldn't find {git_path}")

    ''' Call git add and git commit on the specified files '''
    def commit_files(self, file_specifier=None, comment=None):
        os.chdir(self.full_path)

        if file_specifier == None:
            file_specifier = "*.txt"

        if comment == None:
            comment = 'C{}'.format(self.commit_count+1)

        command = f"git add {file_specifier} "
        result = os.system(command)

        command = f'git commit -m "{comment}"'
        print(f"Command: {command}")
        result = os.system(command)

        self.commit_count += 1

    # ''' Generate and commit a set of changes '''
    def add_commits(self, num_commits, allow_conflicts=False, branch=None):
        os.chdir(Path(self.full_path))

        # if branch != None:
        #     switch_branch(repo_path, branch, create=True)

        next_commit = self.commit_count

        for i in range(1, num_commits+1):
            self.file_builder.touch_files(3, not allow_conflicts)
            self.commit_files()

    ''' Change branches using "switch" '''
    #
    # If the branch does not exist, checkout returns 1
    # 
    def switch_branch(self, branch_name, create=True):

        os.chdir(self.full_path)
        
        if create == True:
            # Attempt to create the branch
            # This will fail if the branch already exists
            command = f'git switch -c {branch_name}'
            result = os.system(command)
        
        command = f'git switch {branch_name}'
        result = os.system(command)
        print(f"Attempted to switch to branch '{branch_name}' (Result: {result})")


# ''' Generate a list containing a subset of the files in a specified folder '''
# def get_file_list(folder_path, file_spec=None, limit=0, start_with=0, randomize=False):
#     full_path = Path(folder_path, file_spec)
#     full_file_list = glob.glob(str(full_path))
#     if limit == 0:
#             limit = len(full_file_list)
#             print(limit)
#     num_samples = min(limit, len(full_file_list))

#     if randomize == True:
#         samples = random.sample(full_file_list, num_samples)
#     else:
#         samples = full_file_list[start_with:start_with+num_samples]

#     return(samples)

# ''' Modify the specified files by appending a string '''
# def change_files(file_list, message=None):
#     if message == None:
#         current_time = datetime.datetime.now()
#         message = f"Updated file at {current_time}"

#     for file in file_list:
#         command = f"echo {message} >> {file}"
#         os.system(command)


# ''' Create files and adds them to the repo '''
# def populate_repo(repo_path, num_files=1, msg=None):
#     num_files = max(num_files, 1)

#     if msg == None:
#         msg = 'C1'

#     create_files(count=num_files, folder_path=repo_path)
#     commit_files(repo_path, '*.txt', msg)



#
# Main
#
if __name__ == '__main__':
    #
    # Create a repo with an unmerged branch w/o conflicts
    #

    # Define parameters for the repo
    parent_folder = "c:/temp"
    repo_name = 'no_conflicts'

    # Create a new repo containing a set of files
    repo = Repo(repo_name, parent_folder)
    repo.create_repo()
    # repo.add_commits(5)
    # repo.switch_branch('branch1', True)

    # repo.populate_repo(num_files=5)







    # # Modify and commit changes for a feature branch
    # num_commits = 3
    # add_commits(repo_path, branch='new_feature', num_commits=num_commits, commit_index=next_commit, allow_conflicts=False)
    # next_commit += num_commits

    # # Modify and commit changes for the main branch
    # num_commits = 2
    # add_commits(repo_path, branch='master', num_commits=num_commits, commit_index=next_commit, allow_conflicts=False)
    # next_commit += num_commits

    # #
    # # Create a repo with an unmerged branch with conflicts
    # #

    # # Define parameters for the repo
    # parent_folder = "c:/temp"
    # repo_name = 'conflicts'

    # commit_count = 0

    # # Delete the existing repo (including files)
    # danger_delete_folder(Path(parent_folder, repo_name))

    # # Create a new repo containing a set of files
    # repo_path = create_repo(repo_name, parent_folder)
    # populate_repo(repo_path, num_files=5)
    # next_commit = 2

    # # Modify and commit changes for a feature branch
    # num_commits = 3
    # add_commits(repo_path, branch='new_feature', num_commits=num_commits, commit_index=next_commit, allow_conflicts=True)
    # next_commit += num_commits

    # # Modify and commit changes for the main branch
    # num_commits = 2
    # add_commits(repo_path, branch='master', num_commits=num_commits, commit_index=next_commit, allow_conflicts=True)
    # next_commit += num_commits

    # #
    # # Create a repo with multiple unmerged branches
    # #

    # # Define parameters for the repo
    # parent_folder = "c:/temp"
    # repo_name = 'multi_branch'

    # commit_count = 0

    # # Delete the existing repo (including files)
    # danger_delete_folder(Path(parent_folder, repo_name))

    # # Create a new repo containing a set of files
    # repo_path = create_repo(repo_name, parent_folder)
    # populate_repo(repo_path, num_files=20)
    # next_commit = 2

    # # Modify and commit changes for a feature branch
    # num_commits = 3
    # add_commits(repo_path, branch='new_feature', num_commits=num_commits, commit_index=next_commit, allow_conflicts=False)
    # next_commit += num_commits

    # # Modify and commit changes for the main branch
    # num_commits = 2
    # add_commits(repo_path, branch='master', num_commits=num_commits, commit_index=next_commit, allow_conflicts=False)
    # next_commit += num_commits

    # # Modify and commit changes for a hotfix branch
    # num_commits = 3
    # add_commits(repo_path, branch='hotfix', num_commits=num_commits, commit_index=next_commit, allow_conflicts=False)
    # next_commit += num_commits

    # # Try another idea for the hotfix branch
    # num_commits = 3
    # add_commits(repo_path, branch='hotfix_v2', num_commits=num_commits, commit_index=next_commit, allow_conflicts=False)
    # next_commit += num_commits

    # # Iterate on the first idea
    # num_commits = 3
    # add_commits(repo_path, branch='hotfix', num_commits=num_commits, commit_index=next_commit, allow_conflicts=False)
    # next_commit += num_commits

    # # Modify and commit changes for the main branch
    # num_commits = 2
    # add_commits(repo_path, branch='master', num_commits=num_commits, commit_index=next_commit, allow_conflicts=False)
    # next_commit += num_commits