''' Reading and writing to files (https://tinyurl.com/ceyhvjz5) '''

# The typical workflow for a file is to open it, read or write some things
# then close the file.
#
# In Python this can be handled with a context manager which takes care of
# closing the file automatically.
#

# Get a file handle by calling the read function and specifying access
# Access can be r|w|a|r+

sample_file = '_12b_hello.txt'

f = open(sample_file, 'r')
content = f.read()
print('The contents of the file are:')
print(content)
print(f'Calling f.close().  Return: {f.close()}')

# Use a context handler to make sure the file gets closed
with open(sample_file, 'r') as f:
    # Get some info
    print('\nName: ', f.name)
    print('Is Closed : ', f.closed)
    print('Opening Mode: ', f.mode)

    for line in f:
        # Add the end parameter to avoid duplicate newlines
        print(line, end='')

# Write a few lines out to a new file
lines = ['Hello there!', 'I am a new file', 'I have three lines']
with open('temp_output.txt', 'w') as f:
    for line in lines:
        f.write(f'{line}\n')

# Alternatively all lines could be written at once, but newlines must be added
lines = ['Hello there!\n', 'I am a new file\n', 'I have three lines\n']
with open('temp_output.txt', 'a') as f:
    f.write(f'\n*** Second time ***\n')
    f.writelines(lines)




