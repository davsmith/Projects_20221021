''' Lists, Tuples, and Sets (https://tinyurl.com/mr3t2ny5) '''

"""
    Lists can be nested within lists providing functionality
    for multi-dimensional arrays.

    Created: 6/28/2022
    Updated: 6/28/2022
"""

# Create and access a 2-dimensional array
a = [[1,2,3],[4,5,6],[7,8,9]]
print(a)
print(a[1][2])

# Alternate method for creating a 2D array
rows, cols = (3, 5)
arr = [[0]*cols]*rows
print(arr)

