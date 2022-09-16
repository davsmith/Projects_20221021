''' Build a repo with no commits '''

from repo_builder import Repo

# Define parameters for the repo
PARENT_FOLDER = 'c:/temp'
REPO_NAME = 'empty_repo'

repo = Repo(REPO_NAME, PARENT_FOLDER)
repo.create_repo()
