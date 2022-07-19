"""
    PyGame wrapper for Game and Board classes
"""
import pygame
import _board
from polygons import calc_vertices


SCREEN_DIM = SCREEN_DIM_X, SCREEN_DIM_Y = (1024, 768)
APP_NAME = "Gameboard Test App"


def main():
    """ Main code loop """
    pygame.init()
    pygame.display.set_mode(SCREEN_DIM)
    pygame.display.set_caption(APP_NAME)

    space_boundaries = calc_vertices(4, (450, 275), 100, .75)
    print(f'Boundaries: {space_boundaries}')
    space1 = _board.Space(space_boundaries)
    print(f'Space 1: {space1}')

    running = True

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False


if __name__ == "__main__":
    main()
