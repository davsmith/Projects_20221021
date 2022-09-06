''' Examples of using the subprocess module, as documented in OneNote (https://tinyurl.com/3tr624xu) '''
#
# Examples are from the following articles (paraphrased):
#   Running Shell commands in Python, capturing output (https://tinyurl.com/c3m5mh63)
#   Examples of using the Pythong subprocess module (https://tinyurl.com/4wr88xhb)
#
# Created 9/6/2022 -- Dave Smith
#

import subprocess

#
# Run shell commands using check_output()
#
# Run a shell command passing two arguments
# The text argument specifies results are returned as a string rather than bytes
# The shell argument spedifies to launch a new subprocess using the shell environment
#   If this argument is not specified a FileNotFound exception is raised for almost all commands
#
# The output from the shell command is returned as a string
#
print('----------------------------------------------------------')
cmd = ['git', 'show', 'HEAD']
result = subprocess.check_output(cmd, text=True, shell=True)
print(result)
print('----------------------------------------------------------')

#
# Run shell commands using run()
#
# Run a shell command passing one argumet (passed as a list)
# The stdout argument specifies the output should be captured on the resulting object
#
# The resulting object has attributes for:
#   args: The list of arguments passed to the shell command
#   returncode: The exit code from the shell command
#   stdout: The captured output from the shell command (in bytes by default)
#
print('----------------------------------------------------------')
result = subprocess.run(['git', '--version'], stdout=subprocess.PIPE)
result.stdout

# Use the .decode method on the byte class to convert the byte string to a string
print(result.stdout.decode('utf-8'))
print('----------------------------------------------------------')

#
# Run shell commands using Popen()
#
# Run a shell command passing one argument (passed as a list)
# The stdout argument specifies the output from the command should be captured
# The stderr argument specifies the errors reported by the command should be captured
# The shell command specifies to run under a new process
#   If not specified on Windows a FileNotFound exception is raised by almost all methods
#
# The results of the command are retrieved using the communicate() method
#
print('----------------------------------------------------------')
p = subprocess.Popen(['git', '--version'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
out, err = p.communicate()

# Supplemental
# If the shell command is not recognized, the output is recorded on stderr
p = subprocess.Popen(['abadacus', '-a'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
out, err = p.communicate()

# The shell command is run when the Popen method runs (i.e. not when communicate() runs)
p = subprocess.Popen(['echo', 'test', '>>', 'test.txt'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
out, err = p.communicate()
print('----------------------------------------------------------')

# result = subprocess.run(['ping', 'google.com'], capture_output=True)
# print(f"STDOUT:\n{result.stdout}\n\n")
# print(f"STDERR:\n{result.stderr}\n\n")
# print(f"Exit code: {result.returncode}")
# print(f"Args: {result.args}")



# #
# # Example 1
# #
# # Run a shell command using the Popen method
# #

# # Define command as string
# cmd = 'git status'

# # Use shell to execute the command and store it in sp variable
# sp = subprocess.Popen(cmd,shell=True)

# # Store the return code in rc variable
# result_code = sp.wait()

# # Print the content of sp variable
# print(sp)

# #
# # Example 2
# #
# # 

# # Define command as string and then split() into list format
# cmd = 'ping google.com'

# # Use shell to execute the command, store the stdout and stderr in sp variable
# sp = subprocess.Popen(cmd,
#         shell=True,
#         stdout=subprocess.PIPE,
#         stderr=subprocess.PIPE,
#         universal_newlines=True)

# # Store the return code in rc variable
# rc = sp.wait()

# # Separate the output and error by communicating with sp variable.
# # This is similar to Tuple where we store two values to two different variables
# out,err = sp.communicate()

# print('Return Code:',rc,'\n')
# print('output is: \n', out)
# print('error is: \n', err)

# #
# # Example 3
# #
# # Using shell = False
# #
# # Define command as string and then split() into list format
# cmd = 'echo'.split()

# # Check the list value of cmd
# print('command in list format:',cmd,'\n')

# # Use shell=False to execute the command
# sp = subprocess.Popen(cmd,shell=False,stdout=subprocess.PIPE,stderr=subprocess.PIPE,universal_newlines=True)

# # Store the return code in rc variable
# rc = sp.wait()

# # Separate the output and error.
# # This is similar to Tuple where we store two values to two different variables
# out,err = sp.communicate()

# print('Return Code:',rc,'\n')
# print('output is: \n', out)
# print('error is: \n', err)