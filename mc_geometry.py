''' Equations and classes for geometry in minecraft world
Spherical coordinate equations from https://keisan.casio.com/exec/system/1359534351
'''
from enum import Enum, IntEnum, unique
from math import sin, cos, sqrt, radians
from mcpi.minecraft import Minecraft

mc = Minecraft.create()

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
    def __init__(self, origin=(0,0,0), length=5, phi=90, theta=0):
        print("Initializing an instance of MCVector")
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
        
        x = r * round(sin(radians(phi) * cos(radians(theta))),5)
        y = r * round(sin(radians(phi) * sin(radians(theta))),5)
        z = r * round(cos(radians(phi)),5)
        
        return (x,y,z)
    
    @property
    def mc_end_point(self):
        ''' Calculate the end point in MineCraft space '''
        x,y,z = self.end_point
        return(y,z,x)
        

def main():
    print('Running stand alone')
    v1 = MCVector(origin=(0,0,0), length=3, phi=90, theta=180)
    v1.set_direction(Direction.West)
    v1.set_slant(Direction.Up)
    print(v1)
    
    mc.player.setPos(0,0,-5)
    
    org_x, org_y, org_z = v1.origin
    ep_x, ep_y, ep_z = v1.mc_end_point
    mc.setBlocks(-20,0,-20,20,20,20,0)
    mc.setBlock(org_x, org_y, org_z, 1)
    mc.setBlock(org_x, org_y, org_z, 53, 2)
    mc.setBlock(ep_x, ep_y, ep_z, 35, 14)

if __name__ == '__main__':
    main()
else:
    print('Running as a module')