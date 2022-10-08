''' Build a repo merging multiple branches into 'main' '''

from repo_builder import Repo

def build(repo_name, parent_folder=None):
    ''' Build a repo merging multiple branches into 'main' '''
    if parent_folder is None:
        parent_folder = 'c:/temp'

    # Create a new repo with multiple branches, no conflicts
    repo = Repo(repo_name, parent_folder)
    repo.commit_delay = 0
    repo.create_repo(initial_branch='main', num_commits=1)
    repo.add_commits(3, branch='new_feature')
    repo.add_commits(2, branch='main')
    repo.merge_branch('new_feature', 'main')

    repo.add_commits(3, branch='hotfix')
    repo.add_commits(2, branch='hotfix_v2')
    repo.add_commits(3, branch='hotfix')
    repo.add_commits(2, branch='main')
    repo.merge_branch('hotfix_v2', 'hotfix')
    repo.switch_branch('main')

    # repo.create_branch('root2', orphan=True, num_commits=1)

if __name__ == '__main__':
    build('multi_merge')
