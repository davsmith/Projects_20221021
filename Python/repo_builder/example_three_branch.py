''' Build an experimental test repo '''

from repo_builder import Repo

def build(repo_name, parent_folder=None):
    ''' Build an experimental test repo '''
    if parent_folder is None:
        parent_folder = 'c:/temp'

    # Create a new repo with multiple branches, no conflicts
    repo = Repo(repo_name, parent_folder)
    repo.create_repo(initial_branch='main', num_commits=2)
    repo.create_branch(branch='feature1', from_branch='main', num_commits=0)
    repo.create_branch(branch='feature2', from_branch='main', num_commits=0)
    repo.add_commits(num_commits=3, branch='feature1')
    repo.add_commits(num_commits=3, branch='feature2')
    repo.add_commits(num_commits=2, branch='main')

if __name__ == '__main__':
    build('scratch')