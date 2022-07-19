"""
    A module for building a game board
"""
import pygame
from pygame.colordict import THECOLORS

DEFAULT_BORDER_COLOR = THECOLORS["green"]


class Space():
    """
    Class to define a space on a game board
    """

    def __init__(self, vertices):
        self.vertices = vertices
        self.items = []
        self.characters = []
        self.messages = []
        self.display = []
        self.overlays = []
        self.properties = {}
        # self.bounding_rect = self.calc_bounds()
        self.border_color = THECOLORS["white"]
        self.border_width = 1
        self.fill_color = THECOLORS["blue"]

    # def print_center(self):
    #     print("The center is at: " + str(self.center))

    def set_border(self, border_color=None, border_width=1):
        """ Defines the border around the polygon """
        if border_color is None:
            border_color = DEFAULT_BORDER_COLOR
        self.border_color = border_color
        self.border_width = border_width

    def draw(self, dest_surface, border_color=None, border_width=1):
        """ Uses the PyGame draw module to draw the space on a surface """
        if border_color is None:
            if border_width == 0:
                border_color = self.fill_color
            else:
                border_color = self.border_color

        pygame.draw.polygon(dest_surface, border_color,
                            self.vertices, border_width)


def main():
    """ Main code loop """
    space_width, space_height = (100, 100)
    grid_columns, grid_rows = (5, 4)
    grid_origin_x, grid_origin_y = (250, 100)

    pygame.init()
    screen = pygame.display.set_mode((1024, 768))

    # Create a single space
    single_space = Space([(0, 0), (100, 0), (100, 100), (0, 100)])
    single_space.set_border(None, border_width=10)

    # Build a grid
    spaces = []
    for grid_row in range(grid_rows):
        for grid_column in range(grid_columns):
            space_rect = [((grid_column*space_width)+grid_origin_x,
                           (grid_row*space_height)+grid_origin_y),
                          ((grid_column*space_width)+grid_origin_x,
                           ((grid_row+1)*space_height)+grid_origin_y),
                          (((grid_column+1)*space_width)+grid_origin_x,
                           ((grid_row+1)*space_height)+grid_origin_y),
                          (((grid_column+1)*space_width)+grid_origin_x,
                           (grid_row*space_height)+grid_origin_y)]
            spaces.append(Space(space_rect))

    print(f"# spaces: {len(spaces)}")
    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.MOUSEBUTTONDOWN:
                print(f"Mouse clicked at: {event.pos}")
                # hit_spaces = []
                for space in spaces:
                    bounds = space.bounding_rect
                    if bounds.collidepoint(event.pos):
                        print(f"Found a hit in rect {space.calc_bounds()}")
                        space.fillColor = (255, 0, 0)

        for space in spaces:
            space.draw(screen, None, 0)

        for space in spaces:
            space.draw(screen)

        # Draw the single square
        single_space.draw(screen)

        pygame.display.update()


if __name__ == "__main__":
    main()
