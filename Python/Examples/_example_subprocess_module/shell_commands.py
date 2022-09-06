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
# print('----------------------------------------------------------')
# cmd = ['git', 'status', '--short']
# result = subprocess.check_output(cmd, text=True, shell=True)
# print(result)
# print('----------------------------------------------------------')

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
# print('----------------------------------------------------------')
# result = subprocess.run(['git', '--version'], stdout=subprocess.PIPE)
# result.stdout

# # Use the .decode method on the byte class to convert the byte string to a string
# print(result.stdout.decode('utf-8'))
# print('----------------------------------------------------------')

#
# Run shell commands using Popen()
#
# Run a shell command passing one argument (passed as a list)
# The stdout argument specifies the output from the command should be captured
# The stderr argument specifies the errors reported by the command should be captured
# The shell command specifies to run under a new process
#   If not specified on Windows a FileNotFound exception is raised by almost all methods
#
# The Popen method returns a Popen object
#
# The results of the command are retrieved using the communicate() or wait() methods
#
# print('----------------------------------------------------------')
# p = subprocess.Popen(['git', '--version'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
# out, err = p.communicate()

# # Supplemental
# # If the shell command is not recognized, the output is recorded on stderr
# p = subprocess.Popen(['abadacus', '-a'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
# out, err = p.communicate()

# # The shell command is run when the Popen method runs (i.e. not when communicate() runs)
# p = subprocess.Popen(['echo', 'test', '>>', 'tmp_1.txt'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
# out, err = p.communicate()
# print('----------------------------------------------------------')


#
# More examples of using Popen to run shell commands
#
# print('----------------------------------------------------------')

# # Define command as string
# cmd = 'dir /s'

# # Use shell to execute the command and store it in sp variable
# p = subprocess.Popen(cmd,shell=True)

# # Wait up to 3 seconds for the process to exit, and store the result code
# result_code = p.wait(3)

# # Print the content of sp variable
# print(p)
# print('----------------------------------------------------------')

#
# Demonstrate a timeout
#
print('----------------------------------------------------------')
# Define command as string and then split() into list format
cmd = 'ping google.com'

# Use shell to execute the command, store the stdout and stderr in sp variable
p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

# Store the return code in rc variable
try:
    result_code = p.wait(1)
except subprocess.TimeoutExpired:
    print('Command took too long to run')

# Separate the output and error by communicating with sp variable.
# This is similar to Tuple where we store two values to two different variables
out,err = p.communicate()

print('output is: \n', out)
print('error is: \n', err)
print('----------------------------------------------------------')
