''' Demonstrates merging branches where a fast-forward is possible '''

from repo_builder import Repo

# Define parameters for the repo
PARENT_FOLDER = 'c:/temp'
REPO_NAME = 'fast_forward'

# Create a repo with two branches
repo = Repo(REPO_NAME, PARENT_FOLDER)
repo.create_repo(first_branch='main', num_commits=1)
repo.add_commits(5, branch='new_feature')
repo.add_commits(4, branch='hotfix')
repo.graph_branch()
k = input('Press a key')

# Since no commits have been made to main that
# aren't included in the hotfix branch, a merge
# simply means moving the branch pointer for main
# up to the hotfix branch pointer.
#
# This is called a fast-forward, and is noted by git
# as the merge is performed.
#
repo.switch_branch('main')
repo.merge_branch('hotfix')
repo.graph_branch()
k = input('Press a key')
