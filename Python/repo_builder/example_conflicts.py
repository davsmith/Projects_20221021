''' Build a repo where a feature branch deviates from the main branch '''

from repo_builder import Repo

# Define parameters for the repo
PARENT_FOLDER = 'c:/temp'
REPO_NAME = 'conflicts'

# Create a new repo with a feature branch in which
# some files have been changed in both branches
repo = Repo(REPO_NAME, PARENT_FOLDER)
repo.create_repo(first_branch='main', num_commits=2)
repo.add_commits(5, branch='new_feature', create_conflicts=True)
repo.add_commits(2, branch='main', create_conflicts=True)
i = input('Press <Enter>')

# Attempting to merge will cause a merge conflict
#
# In VS Code, switching to the Source Control pane will
# show a 'Merge Changes' section with the conflicts.
#
# Clicking a file will show the conflict and allow for
# which changes to accept.
#
# After the conflict has been resolved, stage and commit the file
#
repo.merge_branch('new_feature')
