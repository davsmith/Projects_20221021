''' Build a repo with no commits '''

from repo_builder import Repo

def build(repo_name, parent_folder=None):
    ''' Build a repo with no commits '''
    if parent_folder is None:
        parent_folder = 'c:/temp'

    repo = Repo(repo_name, parent_folder)
    repo.create_repo()

if __name__ == '__main__':
    build('empty_repo')