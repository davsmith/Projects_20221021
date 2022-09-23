''' A repo with only the 'main' branch '''

from repo_builder import Repo

def build(repo_name, parent_folder=None):
    ''' A repo with only the 'main' branch '''
    if parent_folder is None:
        parent_folder = 'c:/temp'

    repo = Repo(repo_name, parent_folder)
    repo.create_repo(first_branch='main', num_commits=4)
    repo.graph_branch()

if __name__ == '__main__':
    build('simple')
