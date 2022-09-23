''' Create the example repos for repo_builder '''
import example_empty_repo
import example_conflicts
import example_complicated
import example_fast_forward
import example_simple

example_empty_repo.build('1_empty_repo')
example_conflicts.build('2_conflicts')
example_complicated.build('3_complicated')
example_fast_forward.build('4_fast_forward')
example_simple.build('5_simple')
