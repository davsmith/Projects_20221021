''' Template for writing scripts for Minecraft Pi '''
from enum import Enum, IntEnum, unique
from mcpi.minecraft import Minecraft
from mcpi import block
from mcpi.vec3 import Vec3
import mcpi
import math
import time

print(mcpi)
mc = Minecraft.create()

@unique
class Cardinal(IntEnum):
    ''' Specifies the direction a an object along a compass '''
    East = 90
    North = 180
    South = 0
    West = 270
    Flat = -1
    
@unique
class Plane(Enum):
    ''' Defines friendly names for each of the 3 dimensional planes '''
    XY = 0 # East/West
    XZ = 1 # Up/Down
    YZ = 2 # South/North

class Rectangle:
    ''' Definition of rectangular structure for MineCraft Pi '''

    def __init__(self, length, height, origin=None, xz_angle=0):
        if origin is None:
            origin = Vec3(0,0,0)
        
        self.name = ""
        self.length = length
        self.height = height
        self.origin = origin
        self.xz_angle = xz_angle
        self._calc_opposite_corners()

    def __repr__(self):
        msg = f"Rectangle: name={self.name}, origin({self.origin}), opposite_corner_xz({self.opposite_xz}), xz_angle={self.xz_angle}"
        return msg

    def clone(self):
        ''' Creates a copy of the rectangle with the same dimensions '''
        print(f"Cloning rectangle: length={self.length}, height={self.height}, origin={self.origin}, xz_angle={self.xz_angle}")
        # The clone method is called on the origin so that the new wall has a copy of
        # the origin rather than a reference to the same origin
        return Rectangle(self.length, self.height, self.origin.clone(), self.xz_angle)
    
    def _calc_opposite_corners(self):
        print(f"Calculating corners at xz_angle = {self.xz_angle}")
        opposite_x = round((self.length-1) * math.sin((math.pi/180)*self.xz_angle),1)
        opposite_z = round((self.length-1) * math.cos((math.pi/180)*self.xz_angle),1)
        self.opposite_xz = self.origin + Vec3(opposite_x, self.height-1, opposite_z)

    def setDirection(self, direction=Cardinal.East):
        self.xz_angle = int(direction)
        self._calc_opposite_corners()
        
    def rotate(self, angle=0):
        pass
        
    def rotateLeft(self):
        self.xz_angle += 90
        self._calc_opposite_corners()

    def rotateRight(self):
        self.xz_angle -= 90
        self._calc_opposite_corners()
        
    def midpoint(self):
        midpoint_x = (self.opposite_xz.x + self.origin.x)/2
        midpoint_y = (self.opposite_xz.y + self.origin.y)/2
        midpoint_z = (self.opposite_xz.z + self.origin.z)/2
        return Vec3(midpoint_x, midpoint_y, midpoint_z)
#bm_along
    def along(self, distance):
        along_x = round((distance-1) * math.sin((math.pi/180)*self.xz_angle),1)
        along_z = round((distance-1) * math.cos((math.pi/180)*self.xz_angle),1)
        return self.origin + Vec3(along_x, 0, along_z)
        
    def shift(self, offset_x=0, offset_y=0, offset_z=0):
        print(f"Shifting rectangle id={id(self)}, origin={id(self.origin)}")
        self.origin += Vec3(offset_x, offset_y, offset_z)
        self._calc_opposite_corners()

    def delete(self):
        pass
        
    def _draw(self, material=None, subtype=0):
        if material is None:
            material = block.GRASS.id
        x1, y1, z1 = self.origin
        x2, y2, z2 = self.opposite_xz
        mc.setBlocks(x1, y1, z1, x2, y2, z2, material, subtype)
        
        if hasattr(self, "isactive"):
            mc.setBlock(x1, y1, z1, block.TNT.id, 1)
        print(f"Drawing ({x1},{y1},{z1},{x2},{y2},{z2}) with {material}")
        
class Door(Rectangle):
    ''' Position is relative to the origin of the parent wall '''
    def __init__(self, parent_wall, position=None):
        if not isinstance(parent_wall, Wall):
            return None
        self.parent_wall = parent_wall
        
        # If a position is not specified for the door, use the midpoint
        if position == None:
            position = round(self.parent_wall.length / 2) + 1
            
        self.position = position
        self.length = 1
        self.height = 2
        self.origin = self.parent_wall.along(position)
        self.xz_angle = self.parent_wall.xz_angle
        self.material = block.AIR.id
        self._calc_opposite_corners()
        
    def __repr__(self):
        msg = f"Door: parent:{id(self.parent_wall)}, position:{self.position}, origin:{self.origin}"
        return msg

#bm_window
class Window(Rectangle):
    ''' Position is relative to the origin of the parent wall '''
    def __init__(self, parent_wall, position_x=None, position_y=None):
        if not isinstance(parent_wall, Wall):
            return None
        self.parent_wall = parent_wall
        
        # If a position is not specified for the door, use the midpoint
        if position_x == None:
            position_x = round(self.parent_wall.length / 2) + 1
            
        if position_y == None:
            position_y = round(self.parent_wall.height / 2)
        print(f"Position y: {position_y}")
        self.position = position_x
        self.length = 1
        self.height = 1
        self.origin = self.parent_wall.along(position_x) + Vec3(0,position_y-1,0)
        self.xz_angle = self.parent_wall.xz_angle
        self.material = block.AIR.id
        self._calc_opposite_corners()
        
    def __repr__(self):
        msg = f"Window: parent:{id(self.parent_wall)}, origin:{self.origin}"
        return msg


class Wall(Rectangle):
    ''' The parent of a Wall should be a House object '''
    def __init__(self, length, height, origin=None, xz_angle=0):
        super().__init__(length, height, origin, xz_angle)
        self.doors = []
        self.windows = []
        self.parent_house = None
        
    def add_door(self, x = None):
        self.doors.append(Door(self))
        print(self.doors)
        
    def add_window(self, x=None, y=None):
        self.windows.append(Window(self, x, y))
        print(self.windows)
         
    def set_corner_material(self, material):
        print(f"Setting corner material to {material}")
        self.corner_material = material
        
    def _draw(self, material=None, subtype=0):
        super()._draw(material, subtype)
        if hasattr(self, "corner_material"):
            ll_x, ll_y, ll_z = self.origin
            ur_x, ur_y, ur_z = self.opposite_xz
            
            mc.setBlocks(ll_x, ll_y, ll_z, ll_x, ur_y, ll_z, self.corner_material)
            mc.setBlocks(ur_x, ur_y, ur_z, ur_x, ll_y, ur_z, self.corner_material)
        
    def clone(self):
        new_wall = Wall(self.length, self.height, self.origin.clone(), self.xz_angle)
        new_wall.corner_material = self.corner_material
        return new_wall
    
class House():
    def __init__(self):
        walls = []
        
class ConstructionSite():
    def __init__(self, length=25, width=25, height=40, depth=1, origin=None):
        
        # If an origin is not specified, use the space under the player
        if origin is None:
            origin = mc.player.getPos() - Vec3(0,1,0)
        self.origin = origin
        self.length = length
        self.width = width
        self.height = height
        self.depth = depth
        self.base_material = block.STONE.id
        
    def __repr__(self):
        msg = f"length={self.length}, width={self.width}, height={self.height},"
        msg += f" depth={self.depth}, material={self.base_material} at {self.origin}"
        return msg
        
    def clear(self, base_material=None):
        if base_material is None:
            base_material = self.base_material
        
        x1, y1, z1 = self.origin
        x2, y2, z2 = self.origin + Vec3(self.length-1, -self.depth+1, self.width-1)
        
        mc.setBlocks(x1, y1, z1, x2, y2, z2, base_material)
        mc.setBlocks(x1, y1+1, z1, x2, y1+self.height-1, z2, block.AIR.id)

    def _draw_cardinal_hc(self):
        mc.setBlocks(0,0,0,0,2,4, block.SANDSTONE.id)   # South
        mc.setBlocks(0,0,0,0,2,-4, block.TNT.id, 1)     # North
        mc.setBlocks(0,0,0,4,2,0, block.ICE.id)         # East
        mc.setBlocks(0,0,0,-4,2,0, block.WOOD.id)       # West


def bump_player():
    ''' Offsets player position by 1 in all directions '''
    player_x, player_y, player_z = mc.player.getPos()
    mc.player.setPos(player_x+1, player_y+1, player_z+1)


def main():
    ''' Main function '''
    mc.postToChat(f"Player is at {mc.player.getPos()}")
    lot_origin = Vec3(0, 0, 0)
    lot_length = 30
    lot_width = 20
    lot_height = 40
    lot_depth = 2
    setback = 5

    house_length = 9
    house_width = 9
    story_height = 3
    wall_material = block.STONE.id

    site = ConstructionSite(lot_length, lot_width, lot_height, lot_depth, lot_origin)
    site.clear(block.SANDSTONE.id)
    mc.setBlock(lot_origin.x, lot_origin.y, lot_origin.z, block.BEDROCK.id)
    print(site)
    
    house_corner_stone = lot_origin + Vec3(setback, 1, setback)
    wall1 = Wall(house_length, story_height, house_corner_stone, Cardinal.North)
    wall1.setDirection(Cardinal.South)
    wall1.name = "Wall1"
    wall1.set_corner_material(block.GRASS.id)
    wall1.add_door()
    wall1._draw(wall_material)
#bm1
    door = wall1.doors[0]
#d    door.isactive = False
    print(door.origin)
    door._draw(block.AIR.id)
#    mc.setBlock(door.origin.x, door.origin.y, door.origin.z, block.WOOD.id)
    
    wall2 = wall1.clone()
    wall2.name = "Wall 2"
    wall2.rotateLeft()
    wall2.add_window()
    wall2._draw(wall_material)
    window = wall2.windows[0]
    print(window)
    window._draw(block.AIR.id)
    if False:
        wall3 = wall1.clone()
        wall3.name = "Wall 3"
        wall3.shift(house_width-1,0,0)
        wall3._draw(wall_material)

        wall4 = wall2.clone()
        wall4.name = "Wall 4"
        wall4.shift(0,0, house_length-1)
        wall4._draw(wall_material)
        print(wall3)
        print(wall1)
        
        mc.player.setPos(lot_origin.x, lot_origin.y+1, lot_origin.z)
    
    


#    wall2 = wall1.clone()
#    wall2.name = "Wall 2"
#    print(wall1)
#    wall2.shift(1)
#    wall2._draw(block.GRASS.id)
#    wall1._draw(block.ICE.id)
#    print(wall1)
#    print(wall2)
    #mc.player.setPos(-1,8,7  )
#    mc.setBlock(0,0,0, block.GRASS.id)


    if False:
        wall1 = Rectangle(house_width, house_height, Vec3(0,0,0))
        print(f"Wall1: {wall1}")
        wall1._draw(block.SANDSTONE.id,1)

        wall2 = wall1.clone()
        wall2.rotateLeft()
        print(f"Wall2: {wall2}")
        wall2._draw(block.ICE.id,1)

        wall3 = wall2.clone()
        wall3.rotateLeft()
        print(f"Wall3: {wall3}")
        wall3._draw(block.TNT.id,1)

        wall4 = wall3.clone()
        wall4.rotateLeft()
        print(f"Wall4: {wall4}")
        wall4._draw(block.WOOD.id,1)

    if False:
        wall5 = Rectangle(house_width, house_height, Vec3(house_width*2,0,0))
        wall5.setDirection(Cardinal.North)
        print(f"Wall5x: {wall5}")
        wall5._draw(block.TNT.id, 1)

        wall6 = Rectangle(house_width, house_height, Vec3(house_width*2,0,0))
        wall6.setDirection(Cardinal.South)
        print(f"Wall6x: {wall6}")
        wall6._draw(block.SANDSTONE.id, 1)

        wall7 = Rectangle(house_width, house_height, Vec3(house_width*2,0,0))
        wall7.setDirection(Cardinal.East)
        wall7._draw(block.ICE.id, 1)

        wall8 = Rectangle(house_width, house_height, Vec3(house_width*2,0,0))
        wall8.setDirection(Cardinal.West)
        wall8._draw(block.WOOD.id, 1)
        print(f"Wall 8: {wall8}")
        
    if False:
        wall9 = Rectangle(house_width, house_height, Vec3(house_width*3,0,0))
        wall9.rotate(45)
        wall9._draw(block.TNT.id, 1)



if __name__ == '__main__':
    main()
