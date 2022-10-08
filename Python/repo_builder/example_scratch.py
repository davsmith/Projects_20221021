''' Build an experimental test repo '''

from repo_builder import Repo

def build(repo_name, parent_folder=None):
    ''' Build an experimental test repo '''
    # Based on the three_branch example repo

    if parent_folder is None:
        parent_folder = 'c:/temp'

    # Create a new repo with multiple branches, no conflicts
    repo = Repo(repo_name, parent_folder)
    repo.create_repo(initial_branch='main', num_commits=2)
    repo.file_builder.touch_files(count=1)
    repo.commit_files(comment='M')

if __name__ == '__main__':
    build('scratch')
