''' Create the example repos for repo_builder '''
import example_empty_repo
import example_conflicts
import example_complicated
import example_fast_forward
import example_simple
import example_three_branch
import example_multiple_branches
import example_split_branch

example_empty_repo.build('1_empty_repo')
example_conflicts.build('2_conflicts')
example_complicated.build('3_complicated')
example_fast_forward.build('4_fast_forward')
example_simple.build('5_simple')
example_three_branch.build('6_three_branch')
example_multiple_branches.build('7_multi_branch')
example_split_branch.build('8_split')
