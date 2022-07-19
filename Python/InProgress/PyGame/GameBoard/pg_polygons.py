"""Adds pygame functionality the base classes in the geometry module """
from enum import Enum, unique, auto
import pygame
from pygame.color import THECOLORS  # pylint: disable=no-name-in-module
from geometry import Polygon

SCREEN_DIM = SCREEN_DIM_X, SCREEN_DIM_Y = (1024, 768)
APP_NAME = "Pygame Template"


@unique
class LineType(Enum):
    """ Definition of enumerated type for describing a line """
    Invisible = 0
    Solid = auto()
    Dashed = auto()
    Dotted = auto()
    Custom = auto()


class PGPolygon(Polygon):
    """ A polygon class for pygame which adds background and borders to the base Polygon class """

    def __init__(self):
        Polygon.__init__(self, 3, (100, 100), 25, None)
        self.image = None
        self.fill_color = None
        self.border_width = 1
        self.border_type = LineType.Solid
        self.border_color = THECOLORS.WHITE


def main():
    """ Main function for functional testing """
    sides = 5
    center = (200, 200)
    radius = 100
    rotation = None

    for border_type in LineType:
        print(f"Type: {border_type.value}")

    polygon1 = Polygon(sides, center, radius, rotation)
    polygon2 = PGPolygon()
    print(polygon2)

    center_polygon = polygon2

    Polygon.debug_list_vertices(center_polygon.vertices)

    pygame.init()
    screen = pygame.display.set_mode(SCREEN_DIM)
    pygame.display.set_caption(APP_NAME)

    running = True

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

        bounds = pygame.Rect(Polygon.calc_bounds(center_polygon.vertices))
        pygame.draw.rect(screen, THECOLORS["blue"], bounds)
        pygame.draw.polygon(
            screen, THECOLORS["green"], center_polygon.vertices, 2)
        pygame.display.update()


if __name__ == "__main__":
    main()
