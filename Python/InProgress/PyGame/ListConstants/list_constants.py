#
# Creates a file containing the constants and values defined in the pygame.constants module
#
import pygame.constants

const = []
for element in dir(pygame.constants):
    constant_value = getattr(pygame.constants, element)
    if not element.startswith("_"):
        const.append("{}: {}  Value:{}\n".format(element, constant_value.__class__.__name__, constant_value))

with open("constants.txt", "w") as f:
    f.write("from typing import List\n\n\n")
    for line in const:
        f.write(str(line))
    f.write("__all__: List[str]\n")