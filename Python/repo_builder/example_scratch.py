''' Build a repo with multiple branches deviating from 'main' '''

from repo_builder import Repo

# Define parameters for the repo
PARENT_FOLDER = 'c:/temp'
REPO_NAME = 'scratch'

# Create a new repo with multiple branches, no conflicts
repo = Repo(REPO_NAME, PARENT_FOLDER)
repo.create_repo(first_branch='main', num_commits=2)
repo.create_branch(branch='feature1', from_branch='main', num_commits=0)
repo.create_branch(branch='feature2', from_branch='main', num_commits=0)
repo.add_commits(num_commits=3, branch='feature1')
repo.add_commits(num_commits=3, branch='feature2')
repo.add_commits(num_commits=2, branch='main')
