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

@unique
class WallType(IntEnum):
    ''' Specifies whether a wall is an internal or external wall '''
    Perimeter = 0
    Inside = 1

@unique
class Plane(Enum):
    ''' Defines friendly names for each of the 3 dimensional planes '''
    XY = 0 # East/West
    XZ = 1 # Up/Down
    YZ = 2 # South/North

class Rectangle:
    ''' Definition of rectangular structure for MineCraft Pi '''

    def __init__(self, length, height, origin, xz_angle):
        self.name = ""
        self.length = length
        self.height = height
        self.origin = origin
        self.xz_angle = xz_angle
        self.xy_angle = 0
        self.tipped = False
        self._calc_opposite_corners()

    def __repr__(self):
        msg = f"Rectangle: name={self.name}, length={self.length}, height={self.height}, "
        msg += f"origin({id(self.origin)}, {self.origin}), opposite({self.opposite}), "
        msg += f"xz_angle={self.xz_angle} tipped={self.tipped}"
        return msg

    def clone(self):
        ''' Creates a copy of the rectangle with the same dimensions '''
        print(f"Cloning rectangle: length={self.length}, height={self.height}, origin={self.origin}, xz_angle={self.xz_angle}")
        # The clone method is called on the origin so that the new wall has a copy of
        # the origin rather than a reference to the same origin
        return Rectangle(self.length, self.height, self.origin.clone(), self.xz_angle)
    
    def _calc_opposite_corners(self):
        ''' Calculates the opposite corner on the rectange based on origin, length and angle.
            In MineCraft space, the axes are different than convention, so:
            x = East/West
            y = Altitude
            z = South/North
        
            theta = angle between vertical and horizontal planes, yx_angle (0 = vertical)
            phi = angle around the horizontal plane, xz_angle (0 = East?)
            r = the length of the radius (rectangle)
            
            x = r * sin(theta) * cos(phi)
            y = r * cos(theta)
            z = r * sin(theta) * sin(phi)
            
        '''
        theta = math.radians(self.xz_angle)
        opp_sin = round(math.sin(theta))
        opp_cos = round(math.cos(theta))
        
        print(f"Calculating corners at xz_angle = {self.xz_angle} ({self.tipped})")

        opp_x = round((self.length-1) * opp_sin,1)
        opp_y = self.height-1
        opp_z = round((self.length-1) * opp_cos,1)
        
        
        if self.tipped == True:
            print(f"Rectangle is tipped ({self.xz_angle}), sin={opp_sin}, cos={opp_cos}")
            if (opp_sin == 0) and (opp_cos == -1): # 180 degrees
                self.opposite = self.origin + Vec3(opp_y, opp_x, opp_z)
            elif (opp_sin == 0) and (opp_cos == 1): # 0 degrees
                self.opposite = self.origin + Vec3(opp_y, opp_x, opp_z)
            elif (opp_sin == 1) and (opp_cos == 0): # 90 degrees
                self.opposite = self.origin + Vec3(opp_x, opp_z, opp_y)
            elif (opp_sin == -1) and (opp_cos == 0): # 270 degrees
                self.opposite = self.origin + Vec3(opp_x, opp_z, opp_y)
        else:
            self.opposite = self.origin + Vec3(opp_x, opp_y, opp_z)

    def setDirection(self, direction):
        ''' Sets the cardinal direction of a rectangle (e.g. Cardinal.North) '''
        self.xz_angle = int(direction)
        self._calc_opposite_corners()
        
    def rotate(self, angle=0):
        ''' Stubbed out to rotate a rectangle about an axis '''
        pass
        
    def rotateLeft(self):
        ''' Rotates a rectangle counter-clockwise in the x-z (vertical) plane '''
        self.xz_angle += 90
        self._calc_opposite_corners()

    def rotateRight(self):
        ''' Rotates a rectangle clockwise in the x-z (vertical) plane '''
        self.xz_angle -= 90
        self._calc_opposite_corners()
        
    def flip_origin(self):
        ''' Switches the origin of the rectangle to the other end (at the same height) '''
        origin_y = self.origin.y
        self.origin = self.opposite
        self.origin.y = origin_y
        self.xz_angle += 180
        self._calc_opposite_corners()
        
    def midpoint(self):
        ''' Returns the mid-point of a rectangle as a 3-d vector '''
        midpoint_x = (self.opposite_xz.x + self.origin.x)/2
        midpoint_y = (self.opposite_xz.y + self.origin.y)/2
        midpoint_z = (self.opposite_xz.z + self.origin.z)/2
        return Vec3(midpoint_x, midpoint_y, midpoint_z)
#bm_along
    def along(self, distance):
        '''
            Returns the x,y,z coordinate of a point along a rectangle
            The point can be beyond the end-points of the rectangle
        '''
        along_x = round((distance-1) * math.sin((math.pi/180)*self.xz_angle),1)
        along_z = round((distance-1) * math.cos((math.pi/180)*self.xz_angle),1)
        return self.origin + Vec3(along_x, 0, along_z)
        
    def shift(self, offset_x=0, offset_y=0, offset_z=0):
        ''' Moves the rectangle in the specified x, y, and z directions '''
        self.origin += Vec3(offset_x, offset_y, offset_z)
        self._calc_opposite_corners()
        
    def tip(self):
        self.tipped = True
        self._calc_opposite_corners()

    def delete(self):
        pass
        
    def _draw(self, material, subtype=0):
        ''' Draws the rectangle in MineCraft space
            Material is specified as an integer or as a constant (e.g. block.GRASS.id)
            Subtype is an integer which affects certain material types as specified in the API
        '''
        x1, y1, z1 = self.origin
        x2, y2, z2 = self.opposite
        mc.setBlocks(x1, y1, z1, x2, y2, z2, material, subtype)
        
    def _draw_origin(self, material=None, subtype=0):
        ''' Marks the origin of a rectangle with the specified material type
            This method is mostly for debugging
        '''
        if material is None:
            material = block.TNT.id
            subtype = 1
        x1, y1, z1 = self.origin
        mc.setBlock(x1, y1, z1, material, subtype)
        
class Door(Rectangle):
    ''' A rectangle object to represent a door '''
    ''' Position is relative to the origin of the parent wall '''
    def __init__(self, parent_wall, position=None):
        if not isinstance(parent_wall, Wall):
            return None
        
        self.parent_wall = parent_wall
        
        # If a position is not specified for the door, use the midpoint at the bottom of the wall
        if position == None:
            position = round(self.parent_wall.length / 2) + 1
            
        length = 1
        height = 2
        origin = self.parent_wall.along(position)
        xz_angle = self.parent_wall.xz_angle
        super().__init__(length, height, origin, xz_angle)
        self.material = block.AIR.id
        self.material_subtype = 0
        self.position = position

        self._calc_opposite_corners()
        
    def __repr__(self):
        msg = f"Door: parent:{id(self.parent_wall)}, position:{self.position}, origin:{self.origin}"
        return msg
    
    def _draw(self, material=None, subtype=0):
        if material is None:
            material = self.material
            subtype = self.material_subtype
        super()._draw(material, subtype)
        

#bm_window
class Window(Rectangle):
    ''' Position is relative to the origin of the parent wall '''
    def __init__(self, parent_wall, position_x=None, position_y=None):
        if not isinstance(parent_wall, Wall):
            return None #BUGBUG:  Should be an exception
        
        # If a position is not specified for the door, use the midpoint
        if position_x == None:
            position_x = round(parent_wall.length / 2) + 1
            
        if position_y == None:
            position_y = round(parent_wall.height / 2)
        
        length = 1
        height = 1
        origin = parent_wall.along(position_x) + Vec3(0,position_y-1,0)
        xz_angle = parent_wall.xz_angle
        super().__init__(length, height, origin, xz_angle)

        self.parent_wall = parent_wall
        self.position_x = position_x
        self.position_y = position_y
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
        self.wall_material = block.TNT.id
        self.wall_material_subtype = 1
        self.parent_house = None
        
    def add_door(self, x = None):
        self.doors.append(Door(self))
        print(self.doors)
        
    def add_window(self, x=None, y=None):
        self.windows.append(Window(self, x, y))
        print(self.windows)
         
    def set_wall_material(self, material, subtype=0):
        print(f"Setting corner material to {material}")
        self.wall_material = material
        self.wall_material_subtype = subtype

    def set_corner_material(self, material, subtype=0):
        print(f"Setting corner material to {material}")
        self.corner_material = material
        self.corner_material_subtype = subtype
        
    def _draw(self, material=None, subtype=0):
        if material is None:
            material = self.wall_material
            subtype = self.wall_material_subtype
        super()._draw(material, subtype)
        if hasattr(self, "corner_material"):
            ll_x, ll_y, ll_z = self.origin
            ur_x, ur_y, ur_z = self.opposite
            
            mc.setBlocks(ll_x, ll_y, ll_z, ll_x, ur_y, ll_z, self.corner_material, self.corner_material_subtype)
            mc.setBlocks(ur_x, ur_y, ur_z, ur_x, ll_y, ur_z, self.corner_material, self.corner_material_subtype)
        for door in self.doors:
            door._draw(block.AIR.id)

        for window in self.windows:
            window._draw(block.AIR.id)
            
                    
    def clone(self):
        new_wall = Wall(self.length, self.height, self.origin.clone(), self.xz_angle)
        new_wall.set_corner_material(self.corner_material, self.corner_material_subtype)
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
        self.ground_material = block.STONE.id
        ground = Rectangle(length, width, origin, 0)
        ground.tip()
        
        self.ground = ground
        
    def __repr__(self):
        msg = f"length={self.length}, width={self.width}, height={self.height},"
        msg += f" depth={self.depth}, material={self.ground_material} at {self.origin}"
        return msg
        
    def clear(self, ground_material=None):
        if ground_material is None:
            ground_material = self.ground_material
        
        x1, y1, z1 = self.origin
        x2, y2, z2 = self.origin + Vec3(self.length-1, -self.depth+1, self.width-1)
        
        mc.setBlocks(x1, y1, z1, x2, y2, z2, ground_material)
        mc.setBlocks(x1, y1+1, z1, x2, y1+self.height-1, z2, block.AIR.id)

def bump_player():
    ''' Offsets player position by 1 in all directions '''
    player_x, player_y, player_z = mc.player.getPos()
    mc.player.setPos(player_x+1, player_y+1, player_z+1)


def main():
    ''' Main function '''
    mc.postToChat(f"Player is at {mc.player.getPos()}")
    
    # Define the parameters of the lot
    lot_origin = Vec3(0, 0, 0)
    lot_length = 30
    lot_width = 20
    lot_height = 40
    lot_depth = 2
    lot_setback = 5
    lot_material = block.STONE.id
    
    # Define the parameters of the house
    house_length = 5
    house_width = 5
    story_height = 3
    
    # Define parameters for the walls
    wall_material = block.WOOD_PLANKS.id
    wall_material_subtype = 1
    corner_material = block.WOOD.id
    corner_material_subtype = 0

    site = ConstructionSite(lot_length, lot_width, lot_height, lot_depth, lot_origin)
    site.clear(lot_material)
#    site._draw_origin(block.BEDROCK.id)
    print(site)
    
    house_corner_stone = lot_origin + Vec3(lot_setback, 1, lot_setback)
    
    walls = []
    wall = Wall(house_length, story_height, house_corner_stone, Cardinal.North)
    wall.setDirection(Cardinal.South)
    wall.name = "Wall1"
    wall.set_wall_material(wall_material, wall_material_subtype)
    wall.set_corner_material(corner_material, corner_material_subtype)
    wall.add_door()
    
    walls.append(wall)
    for index in range(2, 5):
        wall = wall.clone()
        wall.name = f"Wall{index}"
        wall.flip_origin()
        wall.rotateRight()
        wall.add_window()
        walls.append(wall)
        
    for wall in walls:
        wall._draw(wall_material, wall_material_subtype)
        wall._draw_origin()

if __name__ == '__main__':
    main()
