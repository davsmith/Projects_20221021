"""
    Skeleton pygame app

    - Replace screen dimensions with proper values for the app
    - Add relevant event checks
"""
import pygame

SCREEN_DIM = SCREEN_DIM_X, SCREEN_DIM_Y = (1024, 768)
APP_NAME = "Pygame Template"


def main():
    """ Main code loop """
    pygame.init()
    pygame.display.set_mode(SCREEN_DIM)
    pygame.display.set_caption(APP_NAME)

    running = True

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False


if __name__ == "__main__":
    main()
