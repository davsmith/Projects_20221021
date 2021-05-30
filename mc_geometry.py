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
from math import sin, cos, radians


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
    """A 3D vector with coordinate system adapted to Minecraft
    """

    def __init__(self, origin=(0, 0, 0), length=5, phi=90, theta=0):
        self.origin = origin
        self.length = length
        self.phi = phi
        self.theta = theta

    def __repr__(self):
        msg = f"<MCVector> origin:{self.origin}, "
        msg += f"length:{self.length}, "
        msg += f"phi:{self.phi}, "
        msg += f"theta:{self.theta}, "
        msg += f"mc endpoint:{self.mc_end_point} "
        return msg

    def set_direction(self, direction):
        self.theta = direction

    def set_slant(self, slant):
        if slant == Direction.Flat:
            self.phi = 90
        elif slant == Direction.Up:
            self.phi = 0

    @property
    def end_point(self):
        ''' Calculate x,y,z in conventional space '''
        r = self.length
        phi = self.phi
        theta = self.theta

        x = r * round(sin(radians(phi) * cos(radians(theta))), 5)
        y = r * round(sin(radians(phi) * sin(radians(theta))), 5)
        z = r * round(cos(radians(phi)), 5)

        return (x, y, z)

    @property
    def mc_end_point(self):
        ''' Calculate the end point in MineCraft space '''
        x, y, z = self.end_point
        return(y, z, x)


def main():
    """Main function which is run when the program is run standalone
    """
    vec1 = MCVector(origin=(0, 0, 0), length=3,
                    phi=90, theta=Direction.North)
    print(vec1)

    org_x, org_y, org_z = vec1.origin
    ep_x, ep_y, ep_z = vec1.mc_end_point

    print(compare_points(vec1.origin, vec1.mc_end_point))

    if MINECRAFT_EXISTS:
        MC.player.setPos(0, 0, -5)
        MC.setBlocks(-20, 0, -20, 20, 20, 20, 0)
        MC.setBlock(org_x, org_y, org_z, 1)
        MC.setBlock(org_x, org_y, org_z, 53, 2)
        MC.setBlock(ep_x, ep_y, ep_z, 35, 14)


if __name__ == '__main__':
    main()
else:
    print('Running as a module')
