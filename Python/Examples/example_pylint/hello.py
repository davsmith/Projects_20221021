"""
Example of pylint args to get rid of Module <x> has no <y> members (pylint-nomember)
    Check the settings.json.  Note the generated-members argument with a list of modules to ignore.
    Without the argument, pylint reports errors like Module pygame has no init() member.
    Without the pygame specifier all Pylint errors are suppressed.
"""

import json
import pygame

pygame.init()


def setupSomeStuff(val1, val2):
    pass


screen_size = screen_x, screen_y = (1024, 768)
pygame.display.set_mode(screen_size)

running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False


print('Hello world!')
