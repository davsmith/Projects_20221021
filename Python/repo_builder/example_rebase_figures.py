''' Repos for use in the examples of rebase in OneNote '''

from time import sleep
from repo_builder import Repo

def build(repo_name, parent_folder=None):
    ''' Repos for use in the examples of rebase in OneNote '''
    if parent_folder is None:
        parent_folder = 'c:/temp'

    # repo_name = 'rebase1'
    # repo = Repo(repo_name, parent_folder)
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

    repo_name = 'rebase2'
    repo = Repo(repo_name, parent_folder)
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
    