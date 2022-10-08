''' Create the example repos for repo_builder '''
import example_empty_repo
import example_conflicts
import example_complicated
import example_fast_forward
import example_simple
import example_three_branch
import example_multiple_branches
import example_multiple_merge
import example_split_branch

example_empty_repo.build('1_empty_repo')
example_fast_forward.build('2_fast_forward')
example_simple.build('3_simple')
example_split_branch.build('4_split')
example_three_branch.build('5_three_branch')
example_multiple_branches.build('6_multi_branch')
example_multiple_merge.build('7_multi_merge')
example_conflicts.build('8_conflicts')
example_complicated.build('9_complicated')
