''' Edited examples from https://www.golinuxcloud.com/python-subprocess/#:~:text=Using%20python%20subprocess.check_output%20%28%29%20function%201%20The%20subprocess.check_output,code%20was%20non-zero%20it%20raises%20a%20CalledProcessError.%20 '''

import subprocess

# #
# # Run shell commands using check_output()
# #
# # cmd = ['dir', '/s', 's*']
# cmd = 'pingxxx -c google.com'
# result = subprocess.check_output(cmd, text=True, shell=True)
# print(result)

#
# Run shell commands using run()
#
result = subprocess.run(['ping', 'google.com'], capture_output=True)
print(f"STDOUT:\n{result.stdout}\n\n")
print(f"STDERR:\n{result.stderr}\n\n")
print(f"Exit code: {result.returncode}")
print(f"Args: {result.args}")



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