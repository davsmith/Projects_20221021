''' Equations and classes for geometry in minecraft world
Spherical coordinate equations from https://keisan.casio.com/exec/system/1359534351
'''
try:
    from mcpi.minecraft import Minecraft  # pylint: disable=import-error
    MC = Minecraft.create()
    MINECRAFT_EXISTS = True
except ModuleNotFoundError:
    print("*** Could not find Minecraft module ***")
    MINECRAFT_EXISTS = False

from enum import IntEnum, unique
from math import sin, cos, radians, sqrt, atan, degrees
import numpy as NP


def compare_points(point1, point2):
    ''' Compares two points in Minecraft space '''
    direction = ""
    elevation = ""

    x1, y1, z1 = point1
    x2, y2, z2 = point2
    threshold = 1

    if (y2-y1) > threshold:
        elevation = "above"
    elif (y2-y1) < -threshold:
        elevation = "below"

    if (z2-z1) > threshold:
        direction = "SOUTH"
    elif (z2-z1) < -threshold:
        direction = "NORTH"

    if (x2-x1) > threshold:
        direction += "EAST"
    elif (x2-x1) < -threshold:
        direction += "WEST"

    return (elevation, direction)


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


class MCVector:
    """A 3D vector with coordinate system adapted to Minecraft (x=E/W, y=U/D, z=S/N)"""

    def __init__(self, origin=(0, 0, 0), length=1, phi=90, theta=0):
        self.origin = origin
        self.length = length
        self.phi = phi
        self.theta = theta

    def __repr__(self):
        msg = f"<MCVector> origin:{self.origin}, "
        msg += f"length:{self.length}, "
        msg += f"phi:{self.phi}, "
        msg += f"theta:{self.theta}, "
        msg += f"mc endpoint:{self.end_point} "
        return msg

    def set_direction(self, direction):
        '''Sets the rotation of the vector in the x/z Minecraft plane (theta)
            +x = EAST, -x = WEST
            +y = UP, -y = Down
            +z = SOUTH, -z = NORTH'''
        self.theta = direction

    def set_slant(self, slant):
        ''' Sets the rotation of the vector from vertical (phi) '''
        if slant == Direction.FLAT:
            self.phi = 90
        elif slant == Direction.UP:
            self.phi = 0

    @property
    def end_point(self):
        '''Calculate x,y,z in minecraft space
            x is EAST/WEST
            y is UP/Down
            z is SOUTH/NORTH'''
        r = self.length
        phi = self.phi
        theta = self.theta

        z = r * sin(radians(phi)) * cos(radians(theta))
        y = r * cos(radians(phi))
        x = r * sin(radians(phi)) * sin(radians(theta))

        return NP.add((x, y, z), self.origin)


class MCRectangle(MCVector):
    ''' Manages coordinates of a 2D rectangle in MineCraft 3D space '''

    def __init__(self, origin=(0, 0, 0), length=5, height=3, theta=0):
        self.origin = origin
        self.length = length
        self.height = height
        self.phi = Direction.UP
        self.theta = theta
        self.corners = []
        self._tipped = False
        super().__init__(origin, length, self.phi, theta)

    def __repr__(self):
        msg = f"<MCVector> origin:{self.origin}, "
        msg += f"length:{self.length}, "
        msg += f"phi:{self.phi}, "
        msg += f"theta:{self.theta}, "
        msg += f"endpoint:{self.end_point} "
        return msg

    @property
    def opposite(self):
        '''Calculate the endpoint of the diagnol of the rectangle from the origin'''

        # Create a vector from the origin to the diagnol corner of the rectangle
        hypot = sqrt(pow(self.length, 2) + pow(self.height, 2))
        rotation = self.theta
        if self.phi == Direction.FLAT:
            slant = 90
            rotation = degrees(atan(self.length/self.height)) + self.theta
            # print(f"slant={slant}, rotation={rotation}")
        else:
            slant = degrees(atan(self.length/self.height))
        diagnol = MCVector(origin=self.origin, length=hypot,
                           phi=slant, theta=rotation)

        return diagnol.end_point

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


class MCDebug():
    """Functions for setting up MineCraft environment on Raspberry Pi"""

    def clear_space(self):
        """Clears the air above and ground below a fixed space in MineCraft"""
        MC.setBlocks(-50, 0, -50, 50, 50, 50, 0)
        MC.setBlocks(-50, -1, -50, 50, -5, 50, 1)

    def reset_lot(self):
        """Clears out a fixed space and moves the player"""
        self.clear_space()
        MC.player.setPos(-5, 0, -5)

    def draw_wall(self):
        """Draws a set of walls at hard coded coordinates"""
        block_id = 35
        MC.setBlocks(0, 0, 0, 4, 2, 0, block_id, 11)    # Blue
        MC.setBlocks(0, 0, 0, 0, 2, 4, block_id, 13)    # Green
        MC.setBlocks(0, 0, 4, 4, 2, 4, block_id, 4)     # Yellow
        MC.setBlocks(4, 0, 0, 4, 2, 4, block_id, 2)     # Magenta
        MC.setBlock(0, 0, 0, 46, 1)


def main():
    """Main function which is run when the program is run standalone"""
#    rec1 = MCRectangle(origin=(0, 0, 0), length=5,
#                       height=3, theta=Direction.WEST)
#    rec1.is_tipped = False
#    print(f"FLAT rectangle: {rec1.opposite}")
    if MINECRAFT_EXISTS:
        dbg = MCDebug()
        dbg.reset_lot()
        dbg.draw_wall()

#        print(f"Rec1: {rec1}")
#        x1, y1, z1 = rec1.origin
#        x2, y2, z2 = rec1.opposite
#        x1, y1, z1 = (0,0,0)
#        x2, y2, z2 = (5,3,0)
#        print(f"Drawing from {x1},{y1},{z1} to {x2},{y2},{z2} in {block_id}")


if __name__ == '__main__':
    main()
else:
    print('Running as a module')
