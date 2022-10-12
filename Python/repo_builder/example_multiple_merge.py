''' Build a repo merging multiple branches into 'main' '''

from repo_builder import Repo

def build(repo_name, parent_folder=None):
    ''' Build a repo merging multiple branches into 'main' '''
    if parent_folder is None:
        parent_folder = 'c:/temp'

    # Create a new repo with multiple branches, no conflicts
    repo = Repo(repo_name, parent_folder)
    repo.commit_delay = 1
    repo.create_repo(initial_branch='main', num_commits=2)
    repo.add_commits(3, branch='hotfix_117242')
    repo.add_commits(2, branch='main')

    repo.add_commits(3, branch='new_feature_1')
    repo.add_commits(2, branch='main')
    repo.merge_branch('new_feature_1', 'main')
    repo.add_commits(2, branch='main')
    repo.add_commits(2, branch='new_feature_2')
    repo.add_commits(2, branch='main')
    repo.merge_branch('new_feature_2', 'main')
    repo.add_commits(1, branch='main')
    repo.switch_branch('main')

    # repo.create_branch('root2', orphan=True, num_commits=1)

if __name__ == '__main__':
    build('multi_merge')
