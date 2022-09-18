''' A repo with only the 'main' branch '''

from repo_builder import Repo

# Define parameters for the repo
PARENT_FOLDER = 'c:/temp'
REPO_NAME = 'simple'

repo = Repo(REPO_NAME, PARENT_FOLDER)
repo.create_repo(first_branch='main', num_commits=4)
repo.graph_branch()
