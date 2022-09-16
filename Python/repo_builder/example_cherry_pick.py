''' Build a repo from which commits can be cherry picked '''

from repo_builder import Repo

# Define parameters for the repo
PARENT_FOLDER = 'c:/temp'
REPO_NAME = 'cherry_pick'

# Create a new repo with multiple branches, no conflicts
# Created in a for loop so that custom, sequential comments
# could be added.
repo = Repo(REPO_NAME, PARENT_FOLDER)
repo.create_repo(first_branch='main', num_commits=0)
for i in range(1, 11):
    repo.add_commits(1, branch='cherry_pick', comment=f'Add file {i}')
