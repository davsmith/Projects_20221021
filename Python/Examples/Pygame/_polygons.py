"""
    Demonstrates drawing n-sided polygons in Pygame
"""

# pylint: disable=invalid-name
import os
import math

#  Turn off the Pygame welcome message
os.environ["PYGAME_HIDE_SUPPORT_PROMPT"] = "1"
import pygame


def calcVerticies(n, center, radius, r=0):
    """
    Function to calculate the verticies of a polygon given center and radius
    """
    pi2 = 2 * 3.14

    # Calculate verticies
    verticies = []
    for i in range(0, n):
        x = (math.cos(pi2 * i/n + r) * radius) + center[0]
        y = (math.sin(pi2 * i/n + r) * radius) + center[1]
        verticies.append((x,y))

    return verticies

"""
Pygame setup and game loop
"""

# Load the pygame module
pygame.init()

#
# Set up a window to draw in
#
screen = pygame.display.set_mode((800,600))
pygame.display.set_caption("Polygons")

screenCenter = screen.get_rect().center
numSides = 6
rotation = 0
radius = 100

showBoundingRect = False
lineWidth = 1


#
# Game loop
#

running = True

polygonSurface = pygame.Surface((100,100))
polygonRect = polygonSurface.get_rect(center=(200,200))
vert_list = calcVerticies(numSides, (200,200), 100, rotation)

while running:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_LEFT:
                rotation -= 1
                print(f"Rotation: {rotation}")
            elif event.key == pygame.K_RIGHT:
                rotation += 1
                print(f"Rotation: {rotation}")
            elif event.key == pygame.K_COMMA:
                rotation -= .1
                print(f"Rotation: {rotation}")
            elif event.key == pygame.K_PERIOD:
                rotation += .1
                print(f"Rotation: {rotation}")
            elif event.key == pygame.K_EQUALS:
                numSides += 1
                print(f'Incremented sides to {numSides}')
            elif event.key == pygame.K_MINUS:
                if numSides >= 3:
                    numSides -= 1
            elif event.key == pygame.K_r:
                showBoundingRect = not showBoundingRect
            elif pygame.K_0 <= event.key <= pygame.K_9:
                lineWidth = event.key - pygame.K_0
            else:
                print(f'Unrecognized key pressed ({event.key})')
            print(f'Rotation: {rotation}, # sides: {numSides}')

    # Calculate the verticies of the polygon
    vert_list = calcVerticies(numSides, screenCenter, radius, rotation)

    # Erase and redraw the screen
    screen.fill((0,0,0))
    polygonRect = pygame.draw.polygon(screen, (255,0,0), vert_list, lineWidth)

    if showBoundingRect:
        pygame.draw.rect(screen, (255,255,0), polygonRect, 1)
    
    pygame.display.update()