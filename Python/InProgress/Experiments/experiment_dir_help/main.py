import math

print(dir(math))
print(help(math.cos))

for degrees in range(0, 360):
    print(
        f"Degrees: {degrees},  cos: {math.cos(math.pi/180*degrees)},  sin: {math.sin(math.pi/180*degrees)}")
