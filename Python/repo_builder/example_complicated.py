''' Demonstrates merging branches where a fast-forward is possible '''

from repo_builder import Repo
from time import sleep

# Define parameters for the repo
PARENT_FOLDER = 'c:/temp'
REPO_NAME = 'complicated'
DELAY_TIME = 1

# Create a repo with two branches
repo = Repo(REPO_NAME, PARENT_FOLDER)
repo.create_repo(first_branch='main', num_commits=13)
repo.create_branch(branch='new_feature', num_commits=0, from_branch='main')
repo.add_commits(num_commits=1, branch='main')
repo.add_commits(num_commits=17, branch='new_feature')
repo.create_branch(branch='bugfix', num_commits=0, from_branch='new_feature')
# sleep(DELAY_TIME)
repo.add_commits(num_commits=1, branch='new_feature')
# sleep(DELAY_TIME)
repo.add_commits(num_commits=1, branch='bugfix')
# sleep(DELAY_TIME)
repo.merge_branch(source_branch='bugfix', target_branch='new_feature')
sleep(DELAY_TIME)
repo.add_commits(num_commits=1, branch='bugfix')
repo.merge_branch(source_branch='bugfix', target_branch='new_feature')
repo.add_commits(num_commits=9, branch='new_feature')
repo.merge_branch(source_branch='new_feature', target_branch='main')
repo.add_commits(num_commits=4, branch='main')
repo.create_branch(branch='small_feature', num_commits=1, from_branch='main')
repo.add_commits(num_commits=1, branch='main')
repo.merge_branch(source_branch='small_feature', target_branch='main')
repo.add_commits(num_commits=32, branch='main')
repo.create_branch(branch='small_feature_2', num_commits=0, from_branch='main')
repo.add_commits(num_commits=1, branch='main')
repo.add_commits(num_commits=1, branch='small_feature_2')
repo.merge_branch(source_branch='small_feature_2', target_branch='main')
repo.add_commits(num_commits=16, branch='main')
repo.create_branch(branch='small_feature_3', num_commits=1, from_branch='main')
repo.add_commits(num_commits=1, branch='main')
repo.merge_branch(source_branch='small_feature_3', target_branch='main')
# VVV to 118 for final
repo.add_commits(num_commits=2, branch='main')
repo.create_branch(branch='new_feature_2', num_commits=0, from_branch='main')
repo.add_commits(num_commits=4, branch='main')
repo.create_branch(branch='small_feature_4', num_commits=2, from_branch='main')
repo.add_commits(num_commits=1, branch='main')
repo.merge_branch(source_branch='small_feature_4', target_branch='main')
repo.add_commits(num_commits=8, branch='main')
# repo.merge_branch(source_branch='new_feature_2', target_branch='main')
# repo.add_commits(num_commits=1, branch='new_feature_2')
# repo.graph_branch()
# input('Press a key')
