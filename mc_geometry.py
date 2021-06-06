''' Equations and classes for geometry in minecraft world
Spherical coordinate equations from https://keisan.casio.com/exec/system/1359534351
'''
try:
    from mcpi.minecraft import Minecraft
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
        direction = "South"
    elif (z2-z1) < -threshold:
        direction = "North"

    if (x2-x1) > threshold:
        direction += "East"
    elif (x2-x1) < -threshold:
        direction += "West"

    return (elevation, direction)


@unique
class Direction(IntEnum):
    '''
        Specifies the direction of an object with methods for rotation
        along different axes
    '''
    East = 90
    North = 180
    South = 0
    West = 270
    Flat = -270
    Up = -360


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
            +x = East, -x = West
            +y = Up, -y = Down
            +z = South, -z = North'''
        self.theta = direction

    def set_slant(self, slant):
        ''' Sets the rotation of the vector from vertical (phi) '''
        if slant == Direction.Flat:
            self.phi = 90
        elif slant == Direction.Up:
            self.phi = 0

    @property
    def end_point(self):
        '''Calculate x,y,z in minecraft space
            x is East/West
            y is Up/Down
            z is South/North'''
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
        self.phi = Direction.Up
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
        if self.phi == Direction.Flat:
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
        return self.phi == Direction.Flat

    @is_tipped.setter
    def is_tipped(self, tipped):
        '''Set the rectangle to vertical or flat'''
        if tipped:
            self.phi = Direction.Flat
        else:
            self.phi = Direction.Up


def main():
    """Main function which is run when the program is run standalone"""
    rec1 = MCRectangle(origin=(0, 0, 0), length=5,
                       height=3, theta=Direction.West)
    rec1.is_tipped = True
    print(f"Flat rectangle: {rec1.opposite}")
    if MINECRAFT_EXISTS:
        MC.player.setPos(0, 0, -5)
        # MC.setBlocks(-20, 0, -20, 20, 20, 20, 0)
        # MC.setBlock(org_x, org_y, org_z, 1)
        # MC.setBlock(org_x, org_y, org_z, 53, 2)
        # MC.setBlock(ep_x, ep_y, ep_z, 35, 14)


if __name__ == '__main__':
    main()
else:
    print('Running as a module')
