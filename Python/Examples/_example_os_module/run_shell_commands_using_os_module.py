'''
    Example of using the system method of the os module to execute a shell command

    Dave Smith
    August 12, 2022

'''
import os
 
# Print out the python version
command = "python --version" #command to be executed

# The system method returns the command exist status 
res = os.system(command)
print("Returned Value: ", res)

# Create a set of files
for i in range(1,11):
    command = f"echo This is file {i} > file{i}.txt"
    res = os.system(command)
    print("Returned Value: ", res)
