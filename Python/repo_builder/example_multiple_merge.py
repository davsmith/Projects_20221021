''' Build a repo with multiple branches deviating from 'main' '''

from repo_builder import Repo

# Define parameters for the repo
PARENT_FOLDER = 'c:/temp'
REPO_NAME = 'multi_merge'

# Create a new repo with multiple branches, no conflicts
repo = Repo(REPO_NAME, PARENT_FOLDER)
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
