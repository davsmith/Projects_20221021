#  Turn off the welcome message
import os
os.environ["PYGAME_HIDE_SUPPORT_PROMPT"] = "1"

import pygame

#
# Set environment variables to effect behavior of Pygame
#


#
# Load and initialize Pygame
#

result = pygame.init()
print(result)

sprite = pygame.image.load('intro_ball.gif')
screen = pygame.display.set_mode((640,480))
pygame.display.set_caption("Grid Puzzle 2")
screen.blit(sprite, (0, 0))


running = True
while (running):
    for event in pygame.event.get():
        if (event.type == pygame.QUIT):
            running = False
    pygame.display.update()
