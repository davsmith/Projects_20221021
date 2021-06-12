''' Equations and classes for geometry in minecraft world
Spherical coordinate equations from https://keisan.casio.com/exec/system/1359534351
'''
try:
    from mcpi.minecraft import Minecraft  # pylint: disable=import-error
    from mcpi import block
    MC = Minecraft.create()
    MINECRAFT_EXISTS = True
except ModuleNotFoundError:
    print("*** Could not find Minecraft package ***")
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

        # Python floating point precision is unruly, so round to 2 digits
        z = round(r * sin(radians(phi)) * cos(radians(theta)), 2)
        y = round(r * cos(radians(phi)), 2)
        x = round(r * sin(radians(phi)) * sin(radians(theta)), 2)

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
        self.material = 35          # Wool
        self.material_subtype = 14  # Red
        self.debug = True
        super().__init__(origin, length, self.phi, theta)

    def __repr__(self):
        x, y, z = self.opposite
        msg = f"<MCRectangle> origin:{self.origin}, "
        msg += f"length:{self.length}, "
        msg += f"phi:{self.phi}, "
        msg += f"theta:{self.theta}, "
        msg += f"opposite:{round(x,2)}, {round(y,2)}, {round(z,2)}"
        return msg
    
    def draw(self):
        x1, y1, z1 = self.origin
        x2, y2, z2 = self.opposite
        print(f"x1:{x1}, y1:{y1}, z1:{z1}, x2:{x2}, y2:{y2}, z2:{z2}")
        if MINECRAFT_EXISTS:
            MC.setBlocks(x1, y1, z1, x2, y2, z2, self.material, self.material_subtype)
            if self.debug:
                MC.setBlock(x1, y1, z1, 46, 1)
        

    @property
    def opposite(self):
        '''Calculate the endpoint of the diagnol of the rectangle from the origin'''

        # Create a vector from the origin to the diagnol corner of the rectangle
        hypot = sqrt(pow((self.length-1), 2) + pow((self.height-1), 2))
        rotation = self.theta
        
        # Special case a flat rectangle to appear as tipped
        if self.phi == Direction.FLAT:
            slant = 90
            rotation = degrees(
                atan((self.height-1)/(self.length-1))) + self.theta
            # print(f"slant={slant}, rotation={rotation}")
        else:
            slant = degrees(atan((self.length-1)/(self.height-1)))
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
    @staticmethod
    def clear_space():
        """Clears the air above and ground below a fixed space in MineCraft"""
        MC.setBlocks(-50, 0, -50, 50, 50, 50, 0)
        MC.setBlocks(-50, -1, -50, 50, -5, 50, 1)

    @staticmethod
    def reset_lot():
        """Clears out a fixed space and moves the player"""
        self.clear_space()
        MC.player.setPos(-5, 0, -5)

    @staticmethod
    def draw_walls():
        if MINECRAFT_EXISTS:
            """Draws a set of walls at hard coded coordinates"""
            block_id = 35
            MC.setBlocks(0, 0, 0, 4, 2, 0, block_id, 11)    # Blue
            MC.setBlocks(0, 0, 0, 0, 2, 4, block_id, 13)    # Green
            MC.setBlocks(0, 0, 4, 4, 2, 4, block_id, 4)     # Yellow
            MC.setBlocks(4, 0, 0, 4, 2, 4, block_id, 2)     # Magenta
            MC.setBlock(0, 0, 0, 46, 1)


def main():
    """Main function which is run when the program is run standalone"""

    cross_origin = (0, 0, 0)
    flat_origin = (0, 0, 10)
    
    MCDebug.clear_space()
#    MCDebug.draw_walls()

    # Vertical rectangles
    rec1 = MCRectangle(origin=cross_origin, length=5,
                       height=3, theta=Direction.EAST)
    rec1.material_subtype = 11 # Blue
    rec1.draw()

    rec2 = MCRectangle(origin=cross_origin, length=5,
                       height=3, theta=Direction.WEST)
    rec2.material_subtype = 3 # Light Blue
    rec2.draw()

    rec3 = MCRectangle(origin=cross_origin, length=5,
                       height=3, theta=Direction.SOUTH)
    rec3.material_subtype = 14 # Red
    rec3.draw()

    rec4 = MCRectangle(origin=cross_origin, length=5,
                       height=3, theta=Direction.NORTH)
    rec4.material_subtype = 6 # Pink
    rec4.draw()

    # Flat rectangles
    rec1 = MCRectangle(origin=flat_origin, length=5,
                       height=3, theta=Direction.EAST)
    rec1.material_subtype = 11 # Blue
    rec1.is_tipped = True
    rec1.draw()
    rec1.is_tipped = False
    rec1.draw()

    rec2 = MCRectangle(origin=flat_origin, length=5,
                       height=3, theta=Direction.WEST)
    rec2.material_subtype = 3 # Light Blue
    rec2.is_tipped = True
    rec2.draw()
    rec2.is_tipped = False
    rec2.draw()

    rec3 = MCRectangle(origin=flat_origin, length=5,
                       height=3, theta=Direction.SOUTH)
    rec3.material_subtype = 14 # Red
    rec3.is_tipped = True
    rec3.draw()
    rec3.is_tipped = False
    rec3.draw()

    rec4 = MCRectangle(origin=flat_origin, length=5,
                       height=3, theta=Direction.NORTH)
    rec4.material_subtype = 6 # Pink
    rec4.is_tipped = True
    rec4.draw()
    rec4.is_tipped = False
    rec4.draw()
    
    



#    rec3 = MCRectangle(origin=(0, 0, 0), length=5,
#                       height=3, theta=Direction.SOUTH)

#    rec4 = MCRectangle(origin=(0, 0, 0), length=5,
#                       height=3, theta=Direction.NORTH)


#    print(rec1)
#    print(f"FLAT rectangle: {rec1.opposite}")
#        dbg.reset_lot()
#        dbg.draw_wall()



if __name__ == '__main__':
    main()
else:
    print('Running as a module')
