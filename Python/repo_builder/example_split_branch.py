''' Build a repo where a feature branch deviates from the main branch '''

from repo_builder import Repo

def build(repo_name, parent_folder=None):
    ''' Build a repo where a feature branch deviates from the main branch '''
    if parent_folder is None:
        parent_folder = 'c:/temp'

    # # Create a new repo with a feature branch, no conflicts
    repo = Repo(repo_name, parent_folder)
    repo.create_repo(first_branch='main', num_commits=1)
    repo.add_commits(5, branch='new_feature')
    repo.add_commits(4, branch='main')
    repo.graph_branch()

if __name__ == '__main__':
    build('split_repo')
