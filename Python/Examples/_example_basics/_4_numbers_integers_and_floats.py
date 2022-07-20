''' Numbers:  Integers and Floats (https://tinyurl.com/yzc9anev) '''

n = 3
f = 4.6789

# Types
print(f'Object type of an integer is: {type(n)}')
print(f'Object type of a floating point number is: {type(f)}')

# Operators
print(f'8+4={8+4}')
print(f'8-4={8-4}')
print(f'8*4={8*4}')
print(f'14/4={14/4}')
print(f'14//4={14//4}')
print(f'2**4={2**4}')
print(f'14%4={14%4}')
print(f'3+4*2={3+4*2}, but (3+4)*2={(3+4)*2}')

# Shorthand operators
n = 1

n += 2
print(f'n={n}')

n -= 1
print(f'n={n}')

n *= 2
print(f'n={n}')

# Built-in math functions
n = -2
pi = 3.141592654
print(f'abs({n}) = {abs(n)}')
print(f'round({pi}, 3) = {round(pi, 3)}')

# Comparators
a = 1
b = 2
c = 1
d = 1.0

print(f"a = {a}, b = {b}, c = {c}, d = {d}")
print(f"a == c: {a==b}")
print(f"a == d: {a==d}")
print(f"a == b: {a==b}")
print(f"a != b: {a!=b}")
print(f"a >= b: {a>=b}")
print(f"a <= b: {a<=b}")
print(f"a < b: {a<b}")
print(f"a > b: {a>b}")
print(f"a is c: {a is c}")  # True because they point to the same object
print(f"a is d: {a is d}")  # False because values are same, but objects are different

# Casting
print(f'Change the type of a variable with int(), float(), and str()')
print(f'float("2.0") becomes a {type(float("2.0"))}')

