''' Build a repo with multiple branches deviating from 'main' '''

from repo_builder import Repo

def build(repo_name, parent_folder=None):
    ''' Build a repo with no commits '''
    if parent_folder is None:
        parent_folder = 'c:/temp'

    # Create a new repo with multiple branches, no conflicts
    repo = Repo(repo_name, parent_folder)
    repo.create_repo(initial_branch='main', num_commits=1)
    repo.add_commits(3, branch='new_feature')
    repo.add_commits(2, branch='main')
    repo.add_commits(3, branch='hotfix')
    repo.add_commits(3, branch='hotfix_v2')
    repo.add_commits(3, branch='hotfix')
    repo.add_commits(2, branch='main')

if __name__ == '__main__':
    build('multi_branch')
    