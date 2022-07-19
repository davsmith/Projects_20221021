""" Module doc string """
import sys
import os

print(f"Python interpreter: {sys.executable}")
print(f"Environment variables:")
for variable in os.environ:
    print(variable)
print(" >>> " + os.environ["GIT_ASKPASS"])
print(" >>> " + os.environ["LAYLA"])
