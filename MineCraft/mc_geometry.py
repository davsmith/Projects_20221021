''' Equations and classes for geometry in minecraft world
Spherical coordinate equations from https://keisan.casio.com/exec/system/1359534351
'''

from enum import IntEnum, unique
from math import sin, cos, radians, sqrt, atan, degrees, floor
import materials
import copy
LOG_LEVEL = 9


def dbg_print(msg, level=5):
    """ Prints a string based on the debug level set at the global scope """
    if LOG_LEVEL >= level:
        print(">>> " + msg)


try:
    # pylint: disable=import-error
    from mcpi.minecraft import Minecraft
    from mcpi import materials
    MC = Minecraft.create()
    MINECRAFT_EXISTS = True
except ModuleNotFoundError:
    dbg_print("Couldn't find MineCraft module", 3)
    MINECRAFT_EXISTS = False


@unique
class Direction(IntEnum):
    '''
        Specifies the direction of an object with methods for rotation
        along different axes
    '''
    EAST = 90
    NORTH = 180
    SOUTH = 0
    WEST = 270
    FLAT = -270
    UP = -360


# bmComponent
class MCComponent:
    """Base class for all MineCraft components.
    It provides a few properties common to all components, and debug info"""

    def __init__(self, name, origin):
        """Set the name and origin for the object
        The origin is a tuple consisting of x, y, and z"""
        self.name = name
        self.origin = origin
        self.debug = True

    def _repr__(self):
        """Returns a string used with print <object>"""
        msg = f"<MCComponent: {self.name}> "
        msg += f"origin:{self.origin}, "

    def _draw_origin(self, material=materials.TNT, subtype=0):
        x, y, z = self.origin
        if MINECRAFT_EXISTS:
            MC.setBlock(x, y, z, material, subtype)


# bmVector
class MCVector(MCComponent):
    """A 3D vector with coordinate system adapted to Minecraft (x=E/W, y=U/D, z=S/N)"""

    def __init__(self, origin=(0, 0, 0), length=1, phi=90, theta=0):
        super().__init__("MCVector", origin)
        self.length = length
        self.phi = phi
        self.theta = theta

    def __repr__(self):
        msg = f"<MCVector: {self.name}> origin:{self.origin}, "
        msg += f"length:{self.length}, "
        msg += f"phi:{self.phi}, "
        msg += f"theta:{self.theta}, "
        msg += f"endpoint:{self.end_point} "
        return msg

    def set_direction(self, direction):
        """Sets the rotation of the vector in the x/z Minecraft plane (theta)
            +x = EAST, -x = WEST
            +y = UP, -y = Down
            +z = SOUTH, -z = NORTH"""
        self.theta = direction

    def set_slant(self, slant):
        """Sets the rotation of the vector from vertical (phi)"""
        if slant == Direction.FLAT:
            self.phi = 90
        elif slant == Direction.UP:
            self.phi = 0

    @property
    def end_point(self):
        """Calculate x,y,z in minecraft space
            x is EAST/WEST
            y is UP/Down
            z is SOUTH/NORTH"""
        r = self.length
        phi = self.phi
        theta = self.theta

        # Python floating point precision is unruly, so round to 2 digits
        z = round(r * sin(radians(phi)) * cos(radians(theta)), 2)
        y = round(r * cos(radians(phi)), 2)
        x = round(r * sin(radians(phi)) * sin(radians(theta)), 2)

        return tuple(map(lambda x, y: x + y, (x, y, z), self.origin))


# bmRectangle
class MCRectangle(MCVector):
    """Manages coordinates of a 2D rectangle in MineCraft 3D space"""

    def __init__(self, origin=(0, 0, 0), length=5, height=3, theta=0):
        self.name = "Rectangle"
        self.origin = origin
        self.length = length
        self.height = height
        self.phi = Direction.UP
        self.theta = theta
        self._tipped = False
        self.material = materials.WOOL    # Wool - 35
        self.material_subtype = 14       # Red
        self.debug = True
        super().__init__(origin, length, self.phi, theta)

    def __repr__(self):
        msg = f"<MCRectangle {self.name}> origin:{self.origin}, "
        msg += f"length:{self.length}, "
        msg += f"height:{self.height}, "
        msg += f"phi:{self.phi}, "
        msg += f"theta:{self.theta}, "
        msg += f"material:({self.material}, {self.material_subtype}), "
        msg += f"opposite:{self.opposite}, "
        msg += f"is_tipped:{self.is_tipped}"
        return msg

    def copy(self, extend=False):
        """Makes a copy of the existing object"""

        dbg_print(f"Copying {self.name} of type {type(self)}", 9)
        new_rect = copy.deepcopy(self)

        if extend:
            new_rect.flip_origin()

        return new_rect

    def along(self, horizontal=0, vertical=0):
        """Returns the coordinate of the materials <distance> along
        along the bottom of the rectangle (0 is the origin)"""

        return self._calc_opposite_corner(floor(horizontal), floor(vertical))

    def shift(self, x, y, z):
        """Shifts the rectangle by an offset in each direction"""
        origin_x, origin_y, origin_z = self.origin
        self.origin = (origin_x + x, origin_y + y, origin_z + z)

    def rotate_left(self):
        """Rotates a rectangle 90 degrees counter-clockwise"""
        self.theta += 90

    def rotate_right(self):
        """Rotates a rectangle 90 degrees clockwise"""
        self.theta -= 90

    def flip_origin(self):
        """Swaps the origin to the opposite corner at the bottom"""
        origin_x, _, origin_z = self.opposite
        _, origin_y, _ = self.origin
        self.origin = (origin_x, origin_y, origin_z)

    def draw(self):
        """Draws the rectangle based on the origin and opposite
        properties, with the material specified in the material property"""
        x1, y1, z1 = self.origin
        x2, y2, z2 = self.opposite

        msg = f"Drawing rectangle from ({x1},{y1},{z1}) to ({x2},{y2},{z2}) "
        msg += f"in material {self.material} subtype {self.material_subtype}"
        dbg_print(msg, 9)

        if MINECRAFT_EXISTS:
            MC.setBlocks(x1, y1, z1, x2, y2, z2,
                         self.material, self.material_subtype)
            if self.debug:
                self._draw_origin()

    @property
    def opposite(self):
        """Calculate the endpoint of the diagnol of the rectangle from the origin"""
        return self._calc_opposite_corner()

    def _calc_opposite_corner(self, length=None, height=None):
        if length is None:
            length = self.length - 1

        if height is None:
            height = self.height - 1

        # Create a vector from the origin to the diagnol corner of the rectangle
        hypot = sqrt(pow(length, 2) + pow(height, 2))
        rotation = self.theta

        # Special case a flat rectangle to appear as tipped
        if self.phi == Direction.FLAT:
            slant = 90
            rotation = degrees(
                atan(height/length)) + self.theta
        else:
            if height == 0:
                slant = 90
            else:
                slant = degrees(atan(length/height))

        diagnol = MCVector(origin=self.origin, length=hypot,
                           phi=slant, theta=rotation)

        return diagnol.end_point

    @staticmethod
    def _normalize_angle(angle):
        """Make the specified angle fit to 0-360 degrees"""
        normalized_angle = angle
        while normalized_angle < 0:
            normalized_angle += 360
        while normalized_angle >= 360:
            normalized_angle -= 360
        return normalized_angle

    @property
    def is_tipped(self):
        '''Determines if the rectangle is vertical or flat'''
        return self.phi == Direction.FLAT

    @is_tipped.setter
    def is_tipped(self, tipped):
        '''Set the rectangle to vertical or flat'''
        if tipped:
            self.phi = Direction.FLAT
        else:
            self.phi = Direction.UP


# bmWall
class Wall(MCRectangle):
    """A vertically standing wall"""

    def __init__(self, origin, width, height, direction=Direction.NORTH):
        """A wall has an origin a width, a height, and a direction"""
        super().__init__(origin, width, height, direction)
        self.name = "Wall"
        self.is_tipped = False
        self.material = materials.WOOD
        self.material_subtype = 0
        self.corner_material = None
        self.corner_subtype = None
        self.windows = []
        self.doors = []

    def add_window(self, offset_x, offset_y, width, height, material=materials.AIR):
        if offset_x is None:
            offset_x = (self.length - width) / 2
        if offset_y is None:
            offset_y = (self.height - height) / 2

        origin = self.along(offset_x, offset_y)
        new_window = MCRectangle(origin, width, height, self.theta)
        new_window.material = materials.AIR
        new_window.debug = False
        new_window.name = "Window"
        print(new_window)
        self.windows.append(new_window)

    def draw(self):
        super().draw()
        if self.corner_material:
            corner1_x1, corner1_y1, corner1_z1 = self.origin
            _, corner1_y2, _ = self.opposite

            corner2_x1, corner2_y1, corner2_z1 = self.opposite
            _, corner2_y2, _ = self.origin

            dbg_print(f"Drawing corners for {self.name}", 5)
            msg = f"Corner 1: {corner1_x1}, {corner1_y1}, {corner1_z1} "
            msg += f"to {corner1_x1}, {corner1_y2}, {corner1_z1} "
            msg += f"in material {self.corner_material}, subtype {self.corner_subtype}"
            dbg_print(msg, 9)

            msg = f"Corner 2: {corner2_x1}, {corner2_y1}, {corner2_z1} "
            msg += f"to {corner2_x1}, {corner2_y2}, {corner2_z1} "
            msg += f"in material {self.corner_material}, subtype {self.corner_subtype}"
            dbg_print(msg, 9)

            if MINECRAFT_EXISTS:
                MC.setBlocks(corner1_x1, corner1_y1, corner1_z1,
                             corner1_x1, corner1_y2, corner1_z1,
                             self.corner_material, self.corner_subtype)

                MC.setBlocks(corner2_x1, corner2_y1, corner2_z1,
                             corner2_x1, corner2_y2, corner2_z1,
                             self.corner_material, self.corner_subtype)

                for window in self.windows:
                    dbg_print(f"Drawing a window of {window.material}", 9)
                    window.draw()

    # bmSetMaterials
    def set_materials(self, body, corners=None):
        """ Sets the materials of the wall with optional different material
            for the wall corners.
            The body and corner arguments can be numbers or indexable types (e.g. tuples)."""
#        BUGBUG: Document this --> print(type.mro(type((0,0))))

        if hasattr(main, '__iter__'):
            self.material = body[0]
            self.material_subtype = body[1]
        else:
            self.material = body
            self.material_subtype = 0

        if not corners is None:
            if hasattr(corners, '__iter__'):
                self.corner_material = corners[0]
                self.corner_subtype = corners[1]
            else:
                self.corner_material = corners
                self.corner_subtype = 0

# bmLot


class Lot(MCRectangle):
    """The plot of land on which to build a structure

        The direction of the lot indicates the direction
        of the property line along the front of the lot,
        so a direction of North indicates an East facing lot

        The 'across' parameter indicates the width of the lot.
        The 'depth' parameter indicates how far back the lot goes."""

    def __init__(self, origin, depth, across, direction=Direction.NORTH):
        """A lot has an origin, across, depth, and direction"""
        super().__init__(origin, across, depth, direction)
        self.is_tipped = True
        self.material = materials.GRASS
        self.thickness = 5

    def clear(self):
        """Clears the space above and below the lot,
            and redraws the lot in the specified material"""
        origin_x, origin_y, origin_z = self.origin
        opp_x, _, opp_z = self.opposite

        # Clear out the space above the lot
        x1 = origin_x
        y1 = origin_y
        z1 = origin_z
        x2 = opp_x
        y2 = origin_y + self.height
        z2 = opp_z
        MC.setBlocks(x1, y1, z1, x2, y2, z2, materials.AIR)

        # Create a flat rectangle for the lot itself
        self.draw()

        # Set the material for the ground beneath the lot
        x1 = origin_x
        y1 = origin_y - 1
        z1 = origin_z
        x2 = opp_x
        y2 = origin_y - self.thickness
        z2 = opp_z
        MC.setBlocks(x1, y1, z1, x2, y2, z2, materials.BEDROCK)


class MCDebug():
    """Functions for setting up MineCraft environment on Raspberry Pi"""

    @staticmethod
    def clear_space():
        if (MINECRAFT_EXISTS):
            """Clears the air above and ground below a fixed space in MineCraft"""
            MC.setBlocks(-50, 0, -50, 50, 50, 50, 0)
            MC.setBlocks(-50, -1, -50, 50, -5, 50, 1)

    @staticmethod
    def reset_lot():
        """Clears out a fixed space and moves the player"""
        if (MINECRAFT_EXISTS):
            MCDebug.clear_space()
            MC.player.setPos(-5, 0, -5)

    @staticmethod
    def draw_walls():
        """Draws a set of walls at hard coded coordinates"""
        if MINECRAFT_EXISTS:
            block_id = 35
            MC.setBlocks(0, 0, 0, 4, 2, 0, block_id, 11)    # Blue
            MC.setBlocks(0, 0, 0, 0, 2, 4, block_id, 13)    # Green
            MC.setBlocks(0, 0, 4, 4, 2, 4, block_id, 4)     # Yellow
            MC.setBlocks(4, 0, 0, 4, 2, 4, block_id, 2)     # Magenta
            MC.setBlock(0, 0, 0, 46, 1)

    @staticmethod
    def test_draw_vertical_rectangles():
        """Creates and draws rectangles in a + pattern"""
        origin = (0, 0, 0)

        # Vertical rectangles
        rec1 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.EAST)
        rec1.material_subtype = 11  # Blue
        rec1.draw()

        rec2 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.WEST)
        rec2.material_subtype = 3  # Light Blue
        rec2.draw()

        rec3 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.SOUTH)
        rec3.material_subtype = 14  # Red
        rec3.draw()

        rec4 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.NORTH)
        rec4.material_subtype = 6  # Pink
        rec4.draw()

    @staticmethod
    def draw_flat_rectangles():
        """Creates and draws rectangles and their 'tipped' equivalent
        The rectangles should be 4 'L' shaped structures in a + pattern"""
        origin = (0, 0, 10)
        rec1 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.EAST)
        rec1.material_subtype = 11  # Blue
        rec1.is_tipped = True
        rec1.draw()
        rec1.is_tipped = False
        rec1.draw()

        rec2 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.WEST)
        rec2.material_subtype = 3  # Light Blue
        rec2.is_tipped = True
        rec2.draw()
        rec2.is_tipped = False
        rec2.draw()

        rec3 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.SOUTH)
        rec3.material_subtype = 14  # Red
        rec3.is_tipped = True
        rec3.draw()
        rec3.is_tipped = False
        rec3.draw()

        rec4 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.NORTH)
        rec4.material_subtype = 6  # Pink
        rec4.is_tipped = True
        rec4.draw()
        rec4.is_tipped = False
        rec4.draw()

    @staticmethod
    def draw_rotated_rectangles():
        """ Exercises the rotate functionality on the Rectangle class
        The result should be 4 walls in a + pattern"""
        origin = (0, 0, 0)

        # Vertical rectangles
        rec1 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.EAST)
        rec1.material_subtype = 11  # Blue
        rec1.draw()

        rec1.material_subtype = 3  # Light Blue
        rec1.rotate_right()
        rec1.draw()

        rec1.material_subtype = 14  # Red
        rec1.rotate_right()
        rec1.draw()

        rec1.material_subtype = 6  # Pink
        rec1.rotate_right()
        rec1.draw()

    @staticmethod
    def draw_copied_rectangles():
        """Creates a rectangle and copies it to a second rectangle
        Result is two rectangles, the second offset the first by 5 spaces"""

        origin = (0, 0, 0)
        rec1 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.EAST)
        rec1.material_subtype = 11  # Blue
        rec1.draw()

        rec2 = rec1.copy()
        rec2.origin = (0, 0, 5)
#        rec2.rotate_left()
        rec2.material_subtype = 14
        rec2.draw()

        rec1.draw()
        rec1.draw()

    # bm1
    @staticmethod
    def draw_flip_origin():
        """ Draws a rectangle, then flips it around so that the origin is
        at the opposite side of the rectangle"""
        origin = (0, 0, 0)
        rec1 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.WEST)
        rec1.material_subtype = 11  # Blue
        rec1.draw()

        rec2 = rec1.copy(extend=True)
        rec2.material_subtype = 14
        rec2.draw()

    @staticmethod
    def draw_outline():
        """Draws a square shaped structure from 4 walls draw by making
        3 copies of the original wall, and rotating them left"""
        origin = (0, 0, 0)

        rec = MCRectangle(origin=origin, length=5,
                          height=3, theta=Direction.WEST)
        rec.material_subtype = 11  # Blue
        rec.draw()

        for i in range(3):
            rec = rec.copy(extend=True)
            rec.material_subtype = i
            rec.rotate_left()
            rec.draw()

    @staticmethod
    def draw_lot():
        """ Tests the creation of a job site by clearing a space to build on """
        site = Lot(origin=(0, -1, 0), across=20,
                   depth=50, direction=Direction.NORTH)
        site.name = "Job site"
        print(site)
        site.material = materials.GRASS
        site.clear()

    @staticmethod
    def test_walls():
        """ Draws 4 walls using the Wall class.
        The result should be 4 walls in a square """
        wall1 = Wall((-5, 0, -2), width=5, height=3, direction=Direction.NORTH)
        wall1.set_materials(materials.WOOD_PLANKS, materials.TNT)
        wall2 = wall1.copy(extend=True)
        wall2.rotate_left()
#        wall3 = wall2.copy(extend=True)
#        wall3.rotate_left()
#        wall4 = wall3.copy(extend=True)
#        wall4.rotate_left()
        print(f"Wall1 - {wall1}")
        print(f"Wall2 - {wall2}")
        wall1.draw()
        wall2.draw()
#        wall3.draw()
#        wall4.draw()

    @staticmethod
    def test_corners():
        """ Draws walls with different corners for the main wall and corners """
        wall1 = Wall((-5, 0, -2), width=5, height=3, direction=Direction.NORTH)
        print(wall1)
#        wall1.set_materials(materials.WOOD, materials.WOOL)
        wall1.draw()

        wall2 = wall1.copy(extend=True)
        wall2.shift(5, 0, 0)
        wall2.set_materials(materials.WOOL, materials.WOOD)
        wall2.draw()

        wall3 = wall2.copy(extend=True)
        wall3.shift(8, 0, 0)
        wall3.rotate_left()
        wall3.set_materials(materials.WOOL, (materials.TNT, 1.7))
        wall3.draw()

        wall4 = wall3.copy(extend=True)
        wall4.shift(8, 0, 0)
        wall4.rotate_left()
        wall4.set_materials((materials.WOOL, 5), (materials.TNT, 1.0))
        wall4.draw()

    @staticmethod
    def test_along_method():
        """ Tests the Rectangle.along method which returns the coordinate of
        a materials along a wall horizontally, vertically or both.
        A successful test will result in two perpendicular walls each with
        a materials of wool somewhere along the line."""
        wall1 = Wall((-5, 0, -2), width=5, height=3, direction=Direction.EAST)
        wall1.draw()
        wall1.name = "Test Along East"

        wall2 = Wall((-5, 0, -2), width=5, height=3, direction=Direction.NORTH)
        wall2.draw()
        wall2.name = "Test Along North"

        x1, y1, z1 = wall1.along(2)
        print(f"x1={x1}, y1={y1}, z1={z1}")
        MC.setBlock(x1, y1, z1, materials.WOOL)

        x2, y2, z2 = wall2.along(2.5, 1.5)
        print(f"x2={x2}, y2={y2}, z2={z2}")
        MC.setBlock(x2, y2, z2, materials.WOOL)

    @staticmethod
    def test_wall_on_lot():
        """ Sets the origin of a wall based on an offset from the lot corner """
        site = Lot(origin=(0, -1, 0), across=20,
                   depth=50, direction=Direction.NORTH)
        site.name = "Job site"
        site.material = materials.GRASS
        site.clear()
#        x,y,z = site.along(4,1)
#        MC.setBlock(x, y+1, z, materials.WOOL)

    def test_windows():
        wall_width = 5
        wall_height = 3
        wall1 = Wall((-5, 0, -2), width=wall_width,
                     height=wall_height, direction=Direction.NORTH)
        wall1.set_materials(materials.WOOD_PLANKS, materials.WOOD)
        wall1.add_window(None, None, 1, 1)
        print(f"Windows in Wall 1: {len(wall1.windows)}")
        wall1.draw()

        wall2 = wall1.copy(extend=True)
        print(f"Windows in Wall 2: {len(wall2.windows)}")
        wall2.rotate_left()
        wall2.draw()


def main():
    """Main function which is run when the program is run standalone"""
    dbg_print("Testing the debug print", 5)
#    MC.postToChat("Hello")
#    MCDebug.reset_lot()
    MCDebug.clear_space()
#    MCDebug.draw_walls()
#    MCDebug.draw_vertical_rectangles()
#    MCDebug.draw_flat_rectangles()
#    MCDebug.draw_rotated_rectangles()
#    MCDebug.draw_copied_rectangles()
#    MCDebug.draw_flip_origin()
#    MCDebug.draw_outline()
#    MCDebug.draw_lot()
#    MCDebug.test_walls()
#    MCDebug.test_along_method()
#    MCDebug.test_wall_on_lot()
#    MCDebug.test_corners()
    MCDebug.test_windows()


if __name__ == '__main__':
    main()
else:
    print('Running as a module')
