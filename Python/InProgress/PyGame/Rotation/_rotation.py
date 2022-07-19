"""
    Skeleton pygame app

    - Replace screen dimensions with proper values for the app
    - Add relevant event checks
"""
import pygame

SCREEN_DIM = SCREEN_DIM_X, SCREEN_DIM_Y = (1024, 768)
APP_NAME = "Pygame Template"


def main():
    triangle = pygame.Surface((100, 100))

    """ Main code loop """
    pygame.init()
    screen = pygame.display.set_mode(SCREEN_DIM)
    pygame.display.set_caption(APP_NAME)

    running = True

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        triangle.fill((120, 120, 120))
        pygame.display.update()


if __name__ == "__main__":
    main()
