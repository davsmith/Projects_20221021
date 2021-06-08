"""Example of using Numpy arrays to add two vectors"""
import numpy as NP

vec1 = (1, 2, 3)
vec2 = (4, 5, 6)
result = tuple(NP.add(vec1, vec2))

print(f"Sum: {result}")
