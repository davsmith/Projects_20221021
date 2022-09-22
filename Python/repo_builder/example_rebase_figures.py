''' Repos for use in the examples of rebase in OneNote '''

from time import sleep
from repo_builder import Repo

# Define parameters for the repo
PARENT_FOLDER = 'c:/temp'

# REPO_NAME = 'rebase1'
# repo = Repo(REPO_NAME, PARENT_FOLDER)
# repo.create_repo(first_branch='branch_2', num_commits=2)
# repo.create_branch(branch='branch_1', num_commits=0)
# sleep(.5)
# repo.add_commits(branch='branch_2', num_commits=1)
# sleep(.5)
# repo.add_commits(branch='branch_1', num_commits=1)
# sleep(.5)
# repo.add_commits(branch='branch_2', num_commits=1)
# sleep(.5)
# repo.add_commits(branch='branch_1', num_commits=1)
# repo.switch_branch('branch_1')
# repo.graph_branch()

REPO_NAME = 'rebase2'
repo = Repo(REPO_NAME, PARENT_FOLDER)
repo.create_repo(first_branch='branch_1', num_commits=2)
repo.create_branch(branch='branch_2', num_commits=3)
sleep(.5)
repo.add_commits(branch='branch_1', num_commits=2)
sleep(.5)
repo.merge_branch('branch_2')
repo.add_commits(branch='branch_1', num_commits=2)
repo.switch_branch('branch_2')
# sleep(.5)
# repo.add_commits(branch='branch_2', num_commits=1)
# sleep(.5)
# repo.add_commits(branch='branch_1', num_commits=1)
# repo.switch_branch('branch_1')
repo.graph_branch()