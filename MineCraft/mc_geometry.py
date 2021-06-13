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

class MCComponent:
    def __init__(self, name, origin):
        self.name = name
        self.origin = origin
        self.debug = True
        
    def _repr__(self):
        msg = f"<MCComponent: {self.name}> "
        msg += f"origin:{self.origin}, "
        
    def _draw_origin(self, material=block.TNT.id, subtype=0):
        x, y, z = self.origin
        MC.setBlock(x, y, z, material, subtype)


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

        return map(lambda x, y: x + y, (x, y, z), self.origin)

#bmRectangle
class MCRectangle(MCVector):
    """Manages coordinates of a 2D rectangle in MineCraft 3D space"""

    def __init__(self, origin=(0, 0, 0), length=5, height=3, theta=0):
        self.origin = origin
        self.length = length
        self.height = height
        self.phi = Direction.UP
        self.theta = theta
        self._tipped = False
        self.material = block.WOOL.id    # Wool - 35
        self.material_subtype = 14       # Red
        self.debug = True
        super().__init__(origin, length, self.phi, theta)

    def copy(self, extend=False):
        new_rect = MCRectangle(self.origin, self.length, self.height, self.theta)
        new_rect.phi = self.phi
        new_rect.material = self.material
        new_rect.material_subtype = self.material_subtype
        if extend:
            new_rect.flip_origin()
       
        return new_rect
    
    def __repr__(self):
        msg = f"<MCRectangle {self.name}> origin:{self.origin}, "
        msg += f"length:{self.length}, "
        msg += f"phi:{self.phi}, "
        msg += f"theta:{self.theta}, "
        msg += f"opposite:{self.opposite}, "
        msg += f"is_tipped:{self.is_tipped}"
        return msg
    
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
        
    def shift(self, x, y, z):
        """Shifts the rectangle by an offset in each direction"""
        origin_x, origin_y, origin_z = self.origin
        self.origin = (origin_x + x, origin_y + y, origin_z + z)

    def draw(self):
        x1, y1, z1 = self.origin
        x2, y2, z2 = self.opposite
        print(f"x1:{x1}, y1:{y1}, z1:{z1}, x2:{x2}, y2:{y2}, z2:{z2}")
        if MINECRAFT_EXISTS:
            MC.setBlocks(x1, y1, z1, x2, y2, z2, self.material, self.material_subtype)
            print(f"Drawing the rectangle")
            if self.debug:
                self._draw_origin()
        
    @property
    def opposite(self):
        """Calculate the endpoint of the diagnol of the rectangle from the origin"""

        # Create a vector from the origin to the diagnol corner of the rectangle
        hypot = sqrt(pow((self.length-1), 2) + pow((self.height-1), 2))
        rotation = self.theta
        
        # Special case a flat rectangle to appear as tipped
        if self.phi == Direction.FLAT:
            slant = 90
            rotation = degrees(
                atan((self.height-1)/(self.length-1))) + self.theta
        else:
            slant = degrees(atan((self.length-1)/(self.height-1)))

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

#bmLot
class lot(MCRectangle):
    """The plot of land on which to build a structure"""
    def __init__(self, origin, length, width, direction=Direction.NORTH):
        """A lot has an origin, length, width, and direction"""
        super().__init__(origin, length, width, direction)
        self.is_tipped = True
        self.material = block.GRASS.id
        self.height = 50
        self.depth = 5
        
    def clear(self):
        """Clears the space above and below the lot,
            and redraws the lot in the specified material"""
        origin_x, origin_y, origin_z = self.origin
        opp_x, opp_y, opp_z = self.opposite
        
        # Clear out the space above the lot
        x1 = origin_x
        y1 = origin_y
        z1 = origin_z
        x2 = opp_x
        y2 = origin_y + self.height
        z2 = opp_z
        MC.setBlocks(x1, y1, z1, x2, y2, z2, block.AIR.id)
        
        # Create a flat rectangle for the lot itself
        self.draw()
        
        # Set the material for the ground beneath the lot
        x1 = origin_x
        y1 = origin_y - 1
        z1 = origin_z
        x2 = opp_x
        y2 = origin_y - self.depth
        z2 = opp_z
        MC.setBlocks(x1, y1, z1, x2, y2, z2, block.BEDROCK.id)


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
        MCDebug.clear_space()
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
            
    @staticmethod
    def draw_vertical_rectangles():
        origin = (0, 0, 0)

        # Vertical rectangles
        rec1 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.EAST)
        rec1.material_subtype = 11 # Blue
        rec1.draw()

        rec2 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.WEST)
        rec2.material_subtype = 3 # Light Blue
        rec2.draw()

        rec3 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.SOUTH)
        rec3.material_subtype = 14 # Red
        rec3.draw()

        rec4 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.NORTH)
        rec4.material_subtype = 6 # Pink
        rec4.draw()
        
    @staticmethod
    def draw_flat_rectangles():
        origin = (0, 0, 10)
        rec1 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.EAST)
        rec1.material_subtype = 11 # Blue
        rec1.is_tipped = True
        rec1.draw()
        rec1.is_tipped = False
        rec1.draw()

        rec2 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.WEST)
        rec2.material_subtype = 3 # Light Blue
        rec2.is_tipped = True
        rec2.draw()
        rec2.is_tipped = False
        rec2.draw()

        rec3 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.SOUTH)
        rec3.material_subtype = 14 # Red
        rec3.is_tipped = True
        rec3.draw()
        rec3.is_tipped = False
        rec3.draw()

        rec4 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.NORTH)
        rec4.material_subtype = 6 # Pink
        rec4.is_tipped = True
        rec4.draw()
        rec4.is_tipped = False
        rec4.draw()

    @staticmethod
    def draw_rotated_rectangles():
        origin = (0, 0, 0)

        # Vertical rectangles
        rec1 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.EAST)
        rec1.material_subtype = 11 # Blue
        rec1.draw()

        rec1.material_subtype = 3 # Light Blue
        rec1.rotate_right()
        rec1.draw()

        rec1.material_subtype = 14 # Red
        rec1.rotate_right()
        rec1.draw()

        rec1.material_subtype = 6 # Pink
        rec1.rotate_right()
        rec1.draw()

    @staticmethod
    def draw_copied_rectangles():
        origin = (0, 0, 0)
        rec1 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.EAST)
        rec1.material_subtype = 11 # Blue
        rec1.draw()
        
        rec2 = rec1.copy()
        rec2.origin = (0,0,5)
#        rec2.rotate_left()
        rec2.material_subtype = 14
        rec2.draw()
        
        rec1.draw()
        rec1.draw()
                       
    #bm1
    @staticmethod        
    def draw_flip_origin():
        origin = (0, 0, 0)
        rec1 = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.WEST)
        rec1.material_subtype = 11 # Blue
        rec1.draw()
        
        rec2 = rec1.copy(extend=True)
        rec2.material_subtype = 14
#        rec2.shift(0,0,5)
#        rec2.flip_origin()
#        rec2.rotate_right()
        rec2.draw()
        
    @staticmethod
    def draw_outline():
        origin = (0, 0, 0)

        rec = MCRectangle(origin=origin, length=5,
                           height=3, theta=Direction.WEST)
        rec.material_subtype = 11 # Blue
        rec.draw()
        
        for i in range(3):
            rec = rec.copy(extend=True)
            rec.material_subtype = i
            rec.rotate_left()
            rec.draw()

    @staticmethod
    def draw_lot():
        site = lot(origin=(0,-1,0), width=5, length=10, direction=Direction.NORTH)
        site.name = "Job site"
        print(site)
        site.material = block.GRASS.id
        site.clear()


def main():
    """Main function which is run when the program is run standalone"""
    MCDebug.reset_lot()
#    MCDebug.draw_walls()
#    MCDebug.draw_vertical_rectangles()
#    MCDebug.draw_flat_rectangles()
#    MCDebug.draw_rotated_rectangles()
#    MCDebug.draw_copied_rectangles()
#    MCDebug.draw_flip_origin()
#    MCDebug.draw_outline()
    MCDebug.draw_lot()
#    job_site = lot((0,-1,0), 40, 10, Direction.NORTH)
#    print(job_site)
#    job_site.draw()
    



if __name__ == '__main__':
    main()
else:
    print('Running as a module')
