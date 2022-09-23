''' Demonstrates merging branches where a fast-forward is possible '''

from repo_builder import Repo

def build(repo_name, parent_folder=None):
    ''' Build a repo with no commits '''
    if parent_folder is None:
        parent_folder = 'c:/temp'

    # Create a repo with two branches
    repo = Repo(repo_name, parent_folder)
    repo.create_repo(first_branch='main', num_commits=1)
    repo.add_commits(5, branch='new_feature')
    repo.add_commits(4, branch='hotfix')
    repo.graph_branch()
    input('Press <enter>')

    # Since no commits have been made to main that
    # aren't included in the hotfix branch, a merge
    # simply means moving the branch pointer for main
    # up to the hotfix branch pointer.
    #
    # This is called a fast-forward, and is noted by git
    # as the merge is performed.
    #
    repo.switch_branch('main', create=False)
    repo.merge_branch('hotfix')
    repo.graph_branch()

if __name__ == '__main__':
    build('fast_forward')
    