''' Build a repo where a feature branch deviates from the main branch '''

from repo_builder import Repo

def build(repo_name, parent_folder=None, interactive=False):
    ''' Build a repo with no commits '''
    if parent_folder is None:
        parent_folder = 'c:/temp'

    # Create a new repo with a feature branch in which
    # some files have been changed in both branches
    repo = Repo(repo_name, parent_folder)
    repo.create_repo(initial_branch='main', num_commits=2)
    repo.add_commits(5, branch='new_feature', create_conflicts=True)
    repo.add_commits(2, branch='main', create_conflicts=True)

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
    if interactive:
        input('Press <Enter>')
        repo.merge_branch('new_feature')

if __name__ == '__main__':
    build('merge_conflicts', 'c:/temp', True)
