''' Build a repo where a feature branch deviates from the main branch '''

from repo_builder import Repo

# Define parameters for the repo
PARENT_FOLDER = 'c:/temp'
REPO_NAME = 'split_branch'

# # Create a new repo with a feature branch, no conflicts
repo = Repo(REPO_NAME, PARENT_FOLDER)
repo.create_repo(first_branch='main', num_commits=1)
repo.add_commits(5, branch='new_feature')
repo.add_commits(4, branch='main')
repo.graph_branch()
