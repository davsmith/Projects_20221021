''' Library to build a series of files, commits, and branches for a git repo '''

# Changes
# -------------------------------------------------------
# - Created 8/12/2022 by Dave Smith
# - 9/10/2022 (972aec) Finished v2 which changes design to be class based
# - 9/12/2022 () Started v3 - Add graph and merge functionality
# - 9/16/2022 () Refectored 'main' to split out example repos into separate files

#
import os
import shutil
import stat

from tempfile import gettempdir
from pathlib import Path

class FileBuilder:
    ''' Creates folders and dummy files '''

    def __init__(self, parent_path, prefix=None, file_type=None):
        ''' Initializes FileBuilder class '''

        if prefix is None:
            prefix = 'tmp_'

        if file_type is None:
            file_type = '.txt'

        self.prefix = Path(prefix)
        self.parent_path = Path(parent_path)
        self.file_type = file_type
        self.index = 1

    def touch_files(self, count, create=True):
        ''' Makes a change to a file so it shows as dirty '''
        prefix = self.prefix
        folder_path = self.parent_path

        if create is True:
            start = self.index
        else:
            start = 1

        for j in range(start, start+count):
            filename = Path(folder_path,f"{prefix}{j}.txt")
            command = f"echo This is file {j} >> {filename}"
            os.system(command)
            self.index += 1

    @staticmethod
    def get_folder_path(folder=None):
        ''' Creates a Path object from a string '''

        if folder is None:
            folder = gettempdir()

        return Path(folder)

    @staticmethod
    def create_folder(directory, parent_folder=None):
        ''' Create a folder from the folder name and parent path '''

        # Parent path to the directory
        parent = FileBuilder.get_folder_path(parent_folder)

        # Full path
        folder_path = os.path.join(parent, directory)
        os.makedirs(folder_path, exist_ok=True)

        return folder_path

    @staticmethod
    def danger_delete_folder(folder_path):
        ''' Delete an entire folder and subfolders '''

        shutil.rmtree(folder_path, onerror=FileBuilder.rmtree_callback_remove_readonly)

    @staticmethod
    def rmtree_callback_remove_readonly(func, path, excinfo):
        ''' Change the mode of read only files '''

        if isinstance(excinfo[1], FileNotFoundError):
            print("File not found.  Ignored.")
        else:
            print(f"Setting write access for {path} ")
            os.chmod(path, stat.S_IWRITE)
            func(path)

class Repo:
    ''' Class representing a git repository '''
    def __init__(self, repo_name, parent_folder=None):
        self.repo_name = repo_name
        self.parent_folder = parent_folder
        self.full_path = Path(self.parent_folder, self.repo_name)
        self.commit_count = 0
        self.file_builder = FileBuilder(self.full_path, 'tmp_')

    def create_repo(self, first_branch=None, num_commits=0):
        ''' Initialize a repo under the current or specified folder '''
        # Delete the existing repo (including files)
        FileBuilder.danger_delete_folder(self.full_path)
        FileBuilder.create_folder(self.repo_name, self.parent_folder)
        os.chdir(self.full_path)

        os.system('git init')

        if first_branch:
            os.system(f'git switch -c {first_branch}')

        self.add_commits(num_commits)

    def remove_repo(self):
        ''' Delete a repo by deleting the .git subfolder '''

        git_path = Path(self.full_path, '.git')
        try:
            shutil.rmtree(git_path)
        except FileNotFoundError:
            print(f"Couldn't find {git_path}")

    def commit_files(self, file_specifier=None, comment=None):
        ''' Call git add and git commit on the specified files '''

        os.chdir(self.full_path)

        if file_specifier is None:
            file_specifier = "*.txt"

        if comment is None:
            comment = f'C{self.commit_count+1}'

        command = f"git add {file_specifier} "
        os.system(command)

        command = f'git commit -m "{comment}"'
        print(f"Command: {command}")
        os.system(command)

        self.commit_count += 1

    def create_branch(self, branch, num_commits, from_branch=None, orphan=False):
        ''' Create a new branch from the current or specified branch '''
        if from_branch is not None:
            self.switch_branch(from_branch, create=False)

        self.switch_branch(branch, create=True, orphan=orphan)
        self.add_commits(num_commits, branch=branch)

    def add_commits(self, num_commits, create_conflicts=False, branch=None,
                    comment=None, num_files=1):
        ''' Generate and commit a set of changes '''

        os.chdir(Path(self.full_path))

        if branch is not None:
            self.switch_branch(branch, create=True)

        for _i in range(1, num_commits+1):
            self.file_builder.touch_files(num_files, not create_conflicts)
            self.commit_files(comment=comment)

    def switch_branch(self, branch_name, create=True, orphan=False):
        ''' Change branches using "switch" '''

        os.chdir(self.full_path)

        if create is True:
            # Attempt to create the branch
            # This will fail if the branch already exists
            command = 'git switch '

            if orphan:
                command += '--orphan '
            else:
                command += '-c '

            command += f'{branch_name}'
            result = os.system(command)

        command = f'git switch {branch_name}'
        result = os.system(command)
        print(f"Attempted to switch to branch '{branch_name}' (Result: {result})")

    def graph_branch(self, branch_name=None):
        ''' Shows a git graph of the specified branch (or current) '''
        if branch_name is not None:
            os.system(f'git switch {branch_name}')

        os.system('git --no-pager log --oneline --decorate --all --graph')

    def merge_branch(self, source_branch, target_branch=None):
        ''' Merges the source branch into the target branch '''
        if target_branch is not None:
            os.system(f'git switch {target_branch}')

        os.system(f'git merge {source_branch}')


#
# Main
#
if __name__ == '__main__':
    # Define parameters for the repo
    PARENT_FOLDER = 'c:/temp'

    # Create a new repo with a feature branch,
    # a hotfix branch, and no conflicts
    REPO_NAME = 'scratch'
    repo = Repo(REPO_NAME, PARENT_FOLDER)
    repo.create_repo(first_branch='main', num_commits=5)
    repo.add_commits(3, branch='new_feature')
    repo.add_commits(1, branch='main')
    repo.create_branch(num_commits=1, branch='new_root', orphan=True)
    