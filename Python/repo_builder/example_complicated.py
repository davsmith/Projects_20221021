''' Demonstrates merging branches where a fast-forward is possible '''

from repo_builder import Repo

# Define parameters for the repo
PARENT_FOLDER = 'c:/temp'
REPO_NAME = 'complicated'

# Create a repo with two branches
repo = Repo(REPO_NAME, PARENT_FOLDER)
repo.create_repo(first_branch='main', num_commits=13)
repo.create_branch(branch='new_feature', num_commits=17, from_branch='main')
repo.add_commits(1, branch='main')
repo.merge_branch(source_branch='new_feature', target_branch='main')
repo.create_branch(branch='bugfix', num_commits=1, from_branch='new_feature')
repo.merge_branch(source_branch='bugfix', target_branch='new_feature')
repo.create_branch(branch='bugfix', num_commits=1, from_branch='new_feature')
repo.merge_branch(source_branch='bugfix', target_branch='new_feature')
# repo.add_commits(1, branch='bugfix')
# repo.add_commits(1, branch='new_feature')
# repo.add_commits(1, branch='bugfix')
# repo.merge_branch(source_branch='bugfix', target_branch='new_feature')
# repo.add_commits(10, branch='new_feature')
# repo.add_commits(5, branch='main')
# repo.add_commits(1, branch='new_feature')
# repo.add_commits(1, branch='main')
# repo.merge_branch(source_branch='new_feature', target_branch='main')
# repo.graph_branch()
# input('Press a key')
