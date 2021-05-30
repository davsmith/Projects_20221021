''' Equations and classes for geometry in minecraft world
Spherical coordinate equations from https://keisan.casio.com/exec/system/1359534351
'''

from math import sin, cos, sqrt, radians
from mcpi.minecraft import Minecraft

mc = Minecraft.create()


class MCVector:
    def __init__(self):
        print("Initializing an instance of MCVector")
        self.origin = (0,0)
        self.length = 10
        self._phi = 0
        self._theta = 0

        

def main():
    pass

if __name__ == '__main__':
    print('Running stand alone')
    v1 = MCVector()
    mc.postToChat('Hello')
else:
    print('Running as a module')