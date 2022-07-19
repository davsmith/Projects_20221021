"""
    Module to build and manipulate polygons from a specified # sides, center, and radius.

    12/31/2020 -- Completed first version of class based polygon (rather than functions)
"""
from math import pi, sin, cos
import pygame


class Polygon:
    """ Class to build polygons from a specified # sides, center, and radius

        - Setting rotation to None calculates a rotation that results in a side
            along the bottom of the polygon (i.e. bottom is flat)
        - Properties are used (rather than directly setting instance variables) so
            vertices are recalculated if the property changes
     """

    def __init__(self, sides, center, radius, rotation=None):
        self._sides = sides
        self._center = center
        self._radius = radius
        self.rotation = rotation
        self._vertices = None
        self.update_vertices()

    @staticmethod
    def calc_bounds(vertices):
        """ Calculates the boundary rectangle for a polygon defined by vertices
        Two is added to the width and height of the rectangle so that the rectangle
        contains the polygon, rather than just aligning """
        x_coords = []
        y_coords = []
        for vertex in vertices:
            x_coords.append(vertex[0])
            y_coords.append(vertex[1])
        return (min(x_coords), min(y_coords), max(x_coords) - min(x_coords)+2,
                max(y_coords) - min(y_coords)+2)

    @staticmethod
    def calc_vertices(num_vertices, center, radius, rotation):
        """Calculates vertices for a n-sided polygon based on specified center, radius, and rotation

        Args:
            num_vertices (int): The number of sides (and thus the number of vertices) to generate
            center (tuple): Coordinates of the center of the polygon to generate
            radius (float): The distance from the center to any of the vertices
            rotation (float): Rotation of the polygon in degrees. Zero sets v1 right of center

        Returns:
            list: The list of vertices that form an n-sided polygon
        """

        # Calculate verticies using x = r * cos(theta), y = r * sin(theta)
        # https://www.youtube.com/watch?v=aHaFwnqH5CU
        vertices = []
        for vertex in range(0, num_vertices):
            vertex_x = (cos(2*pi * vertex/num_vertices +
                            rotation * pi/180) * radius) + center[0]
            vertex_y = (sin(2*pi * vertex/num_vertices +
                            rotation * pi/180) * radius) + center[1]

            vertices.append((vertex_x, vertex_y))

        return vertices

    @staticmethod
    def debug_list_vertices(vert_list):
        """ Prints the coordinates of each vertex to the terminal """
        for index, vertex in enumerate(vert_list):
            print(f"Vertex #{index+1}: {vertex}")

    def update_vertices(self):
        """ Updates polygon vertices based on # sides, center, radius, rotation, and precision """
        self._vertices = self.calc_vertices(
            self._sides, self._center, self._radius, self.rotation)

    @property
    def sides(self):
        """ Getter for sides property """
        return self._sides

    @sides.setter
    def sides(self, value):
        self._sides = value
        self.update_vertices()

    @property
    def vertices(self):
        """ Getter for vertices property """
        return self._vertices

    @property
    def radius(self):
        """ Getter for radius property """
        return self._radius

    @radius.setter
    def radius(self, radius):
        self._radius = radius
        self.update_vertices()

    @property
    def rotation(self):
        """ Getter for rotation property """
        return self._rotation

    @rotation.setter
    def rotation(self, value):
        """
            Setter for rotation property
            If the value is set to None, the rotation is set to define a polygon
            with a side on the bottom (i.e. make the bottom flat)
        """
        if value is None:
            self._rotation = 90 - 180/self.sides
        else:
            self._rotation = value

        self.update_vertices()

    @property
    def center(self):
        """ Getter for rotation property """
        return self._center

    @center.setter
    def center(self, value):
        """ Setter for center property """
        self._center = value
        self.update_vertices()


def main():
    """"-------------------------------------------------------------------------------------------
    Example use of the polygon functions using Pygame for keyboard control

    Keyboard controls:
        Right and left arrows - increase/decrease rotation by 1
        Up and down arrows - increase/decrease rotation by 10
        Space - resets the rotation to 0
        a - sets rotation to None which calculates the rotation required to make the bottom flat
        + (=) and - - Increase/decrease the number of sides of the polygon


    --------------------------------------------------------------------------------------------"""
    num_sides = 6
    rotation = 0.0
    polygon_center = (200, 200)
    polygon_radius = 100

    polygon1 = Polygon(num_sides, polygon_center, polygon_radius, rotation)
    polygon1.debug_list_vertices(polygon1.vertices)

    # Load the pygame module
    pygame.init()

    #
    # Set up a window to draw in
    #
    screen = pygame.display.set_mode((800, 600))
    pygame.display.set_caption("Polygons")

    #
    # Game loop
    #
    running = True

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_LEFT:
                    polygon1.rotation -= 1
                elif event.key == pygame.K_RIGHT:
                    polygon1.rotation += 1
                elif event.key == pygame.K_UP:
                    polygon1.rotation += 10
                elif event.key == pygame.K_DOWN:
                    polygon1.rotation -= 10
                elif event.key == pygame.K_SPACE:
                    polygon1.rotation = 0
                elif event.key == pygame.K_a:
                    polygon1.rotation = None
                elif event.key == pygame.K_EQUALS:
                    polygon1.sides += 1
                elif event.key == pygame.K_MINUS:
                    if polygon1.sides >= 3:
                        polygon1.sides -= 1
                elif event.key == pygame.K_v:
                    Polygon.debug_list_vertices(polygon1.vertices)
                else:
                    print(f'Unrecognized key pressed ({event.key})')

                print(
                    f'Rotation: {polygon1.rotation} degrees, # sides: {polygon1.sides}')

        # Erase and redraw the screen
        screen.fill((0, 0, 0))
        pygame.draw.polygon(screen, (255, 0, 0), polygon1.vertices, 1)
        pygame.draw.circle(screen, (0, 255, 0), polygon1.center, 1)
        pygame.draw.rect(screen, (0, 0, 255),
                         Polygon.calc_bounds(polygon1.vertices), 1)
        pygame.display.update()


if __name__ == "__main__":
    main()
