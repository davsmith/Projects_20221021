'''
    Example of using the system method of the os module to execute a shell command

    Dave Smith
    August 12, 2022

    Reference:
    https://tinyurl.com/3jww9rry


'''
import os
 

 #
 # Use os.system to run commands where output is ignored
 #

# Print out the python version
command = "python --version" #command to be executed

# The system method returns the command exist status 
res = os.system(command)
print("Returned Value: ", res)

#
# Use os.popen to capture the output
#
myCmd = os.popen('python --version').read()
print(myCmd)

myCmd = os.popen('git status').read()
results = myCmd.split('\n')
print(results)
