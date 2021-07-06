''' Equations and classes for geometry in minecraft world
Spherical coordinate equations from https://keisan.casio.com/exec/system/1359534351
'''

from enum import IntEnum, unique
from math import sin, cos, radians, sqrt, atan, degrees, floor
from dataclasses import dataclass
import materials
import copy
LOG_LEVEL = 9


def dbg_print(msg, level=5):
    """ Prints a string based on the debug level set at the global scope """
    if LOG_LEVEL >= level:
        print(">>> " + msg)

def shift(origin, offset_x, offset_y, offset_z):
    """ Returns a tuple with the base point shifted by x, y, and z """
    origin_x, origin_y, origin_z = origin
    return (origin_x+offset_x, origin_y+offset_y, origin_z+offset_z)

try:
    # pylint: disable=import-error
    from mcpi.minecraft import Minecraft
    from mcpi import block
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


@unique
class WallType(IntEnum):
    INTERNAL = 1
    EXTERNAL = 2


@unique
class WallLocation(IntEnum):
    FRONT = 1
    BACK = 2
    SIDE = 3


# bmComponent
@dataclass
class MCComponent:
    """Base class for all MineCraft components.
    It provides a few properties common to all components, and debug info"""

    name: str
    origin: tuple
    
    def __post_init__(self):
        self.debug = True
        

#    def _repr__(self):
#        """Returns a string used with print <object>"""
#        msg = f"<MCComponent: {self.name}> "
#        msg += f"origin:{self.origin}, "

    def _draw_origin(self, material=materials.TNT, subtype=0):
        x, y, z = self.origin
        if MINECRAFT_EXISTS:
            MC.setBlock(x, y, z, material, subtype)
            
    def shift(self, x, y, z):
        """Shifts the origin by an offset in each direction"""
        origin_x, origin_y, origin_z = self.origin
        self.origin = (origin_x + x, origin_y + y, origin_z + z)
        return self.origin
    
    def shift_parallel(self, distance):
        scalar = 90 * (distance/abs(distance))
        self.theta += scalar
        self.origin = self.along(distance)
        self.theta -= scalar
        return self.origin
    
    def shift_perpendicular(self, distance):
        pass


# bmVector
#@dataclass
#class MCVectorDef(MCComponent):
#    length: int
#    phi: int
#    theta: int
 
@dataclass
class MCVector(MCComponent):
    """A 3D vector with coordinate system adapted to Minecraft (x=E/W, y=U/D, z=S/N)"""
    length: int
    phi: int
    theta: int

#    def __init__(self, origin=(0, 0, 0), length=1, phi=90, theta=0):
#        super().__init__("MCVector", origin)
#        self.length = length
#        self.phi = phi
#        self.theta = theta

#    def __repr__(self):
#        msg = f"<{self.name}> origin:{self.origin}, "
#        msg += f"length:{self.length}, "
#        msg += f"phi:{self.phi}, "
#        msg += f"theta:{self.theta}, "
#        msg += f"endpoint:{self.end_point} "
#        return msg
    def __post_init__(self):
        super().__post_init__()

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
        # BUGBUG: Raise an exception if not FLAT or UP
        
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
@dataclass
class MCRectangleDef(MCVector):
    material: int=materials.WOOL
    material_subtype: int=14

@dataclass
class MCRectangle(MCVector):
    """Manages coordinates of a 2D rectangle in MineCraft 3D space"""
    height: int
    material: int
    material_subtype: int

    def __post_init__(self):
        super().__post_init__()


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
        the bottom of the rectangle (0 is the origin)"""

        return self._calc_opposite_corner(floor(horizontal), floor(vertical))

    def rotate_left(self):
        """Rotates a rectangle 90 degrees counter-clockwise"""
        self.theta += 90

    def rotate_right(self):
        """Rotates a rectangle 90 degrees clockwise"""
        self.theta -= 90

    def flip_origin(self, keep_direction=True):
        """Swaps the origin to the opposite corner at the bottom"""
        origin_x, _, origin_z = self.opposite
        _, origin_y, _ = self.origin
        self.origin = (origin_x, origin_y, origin_z)
        if not keep_direction:
            self.theta += 180
        
    def shrink(self, amount):
        self.origin = self.along(amount, amount)
        self.length -= 2*amount
        self.height -= 2*amount

    def draw(self, material=None, subtype=None):
        """Draws the rectangle based on the origin and opposite
        properties, with the material specified in the material property"""
        x1, y1, z1 = self.origin
        x2, y2, z2 = self.opposite
        
        if material is None:
            material = self.material
            
        if subtype is None:
            subtype = self.material_subtype

        msg = f"Drawing rectangle from ({x1},{y1},{z1}) to ({x2},{y2},{z2}) "
        msg += f"in material {self.material} subtype {self.material_subtype}"
        dbg_print(msg, 9)

        if MINECRAFT_EXISTS:
            MC.setBlocks(x1, y1, z1, x2, y2, z2,
                         material, subtype)
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

        diagnol = MCVector(name="Vector", origin=self.origin, length=hypot,
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

    @staticmethod
    def _normalize_angle(angle):
        """Make the specified angle fit to 0-360 degrees"""
        normalized_angle = angle
        while normalized_angle < 0:
            normalized_angle += 360
        while normalized_angle >= 360:
            normalized_angle -= 360
        return normalized_angle


# bmLot
@dataclass
class Lot(MCComponent):
    """The plot of land on which to build a structure

        The direction of the lot indicates the direction
        of the property line along the front of the lot,
        so a direction of North indicates an East facing lot.

        'length' indicates the width of the lot.
        'height' indicates the depth of the lot.
        'origin' is the corner of the lot in x,y,z.  y is typically -1.
        """
    width: int = 10
    depth: int = 20
    direction: Direction = Direction.EAST
    
    def __post_init__(self):
        super().__post_init__()
        self.thickness = 5
        self.altitude = 50
        self.is_tipped = True
        self.setbacks = (5,5,5,5)
        self.structures = []
        self.surface = None

    def add_surface(self):
        """Defines a flat rectangle to be the top layer of ground"""
        surface_def = {}
        surface_def['name'] = 'Surface_rectangle'
        surface_def['origin'] = self.origin
        surface_def['phi'] = Direction.UP
        surface_def['theta'] = self.direction
        surface_def['length'] = self.width
        surface_def['height'] = self.depth
        surface_def['material'] = materials.GRASS
        surface_def['material_subtype'] = 0
        self.surface = MCRectangle(**surface_def)
        self.surface.is_tipped = True
    
    def add_sky():
        pass
    
    def add_underground():
        pass

    def get_next_structure_origin(self):
        max_left_origin = 0
        max_depth_origin = 0
        setback_front, setback_left, setback_back, setback_right = self.setbacks
        offset_x = max_left_origin + setback_left
        offset_y = max_depth_origin + setback_front
        return self.offset_origin(offset_x, offset_y) 

    def add_structure(self, width, depth, direction, story_height, origin=None):
        if origin is None:
            origin = self.get_next_structure_origin()
        building = Structure(width, depth, direction, story_height, origin )
        return building
        
    def offset_origin(self, x, y):
        x, y, z = self.surface.along(x,y)
        return (x, y+1, z)

    def clear(self, surface_material=None, underground_material=None, sky_material=None):
        """Clears the space above and below the lot, and redraws the lot in
        the specified material.
        
        If no arguments are specified Air, Grass, and Stone are used """

        # BUGBUG: Consider making this a composition of three boxes (sky, surface and crust)
        # BUGBUG: Create a box object which is the 3D version of a rectangle

        if sky_material is None:
            sky_material = materials.AIR
            
        if underground_material is None:
            underground_material = materials.STONE
            
        if surface_material is None:
            surface_material = materials.GRASS
        
        origin_x, origin_y, origin_z = self.origin
        opp_x, _, opp_z = self.surface.opposite

        # Define the space above the lot to clear with air
        sky_start = self.origin
        sky_end = (opp_x, origin_y+self.altitude, opp_z)

        # Define the space beneath the lot
        underground_start = (origin_x, origin_y - 1, origin_z)
        underground_end = (opp_x, origin_y - self.thickness, opp_z)

        if MINECRAFT_EXISTS:
            MC.setBlocks(*sky_start, *sky_end, sky_material)
            MC.setBlocks(*underground_start, *underground_end, underground_material)

            # Create a flat rectangle for the lot itself
            self.surface.draw(surface_material)
            
    def shift_parallel(self, distance):
        print(f"TT: Shifting {self.surface}")
        self.origin = self.surface.shift_parallel(distance)
            
    def set_setbacks(self, front, left=None, back=None, right=None):
        if left is None:
            left = front
            
        if back is None:
            back = front
            
        if right is None:
            right = left
            
        self.setbacks = (front, left, back, right)
        

# bmStructure
@dataclass
class Structure(MCComponent):
    """ A building is a collection of stories, and a roof """
    width: int
    depth: int
    direction: Direction
    story_height: int
    origin: tuple
    
    def __post_init__(self):
        self.foundation = None
        self.stories = []
        self.roof = None
        
    def add_foundation(self):
        foundation_def = {}
        foundation_def['name'] = f'{self.name}_foundation'
        foundation_def['length'] = self.width
        foundation_def['height'] = self.depth
        foundation_def['origin'] = self.origin
        foundation_def['theta'] = self.direction
        foundation_def['phi'] = Direction.UP
        foundation_def['material'] = materials.STONE
        foundation_def['material_subtype'] = 0
        
        self.foundation = MCRectangle(**foundation_def)
        self.foundation.is_tipped = True
        self.foundation.shift(0,-1,0)

    def add_story(self):
        pass
    
    def add_roof(self):
        pass
        
    def draw(self):
        if self.foundation:
            self.foundation.draw()
        for story in self.stories:
            story.draw()
        if self.roof:
            self.roof.draw()
        

# bmWall
@dataclass
class Wall(MCRectangle):
    """A vertically standing wall"""
    location: int = WallLocation.FRONT
    corner_material: int = None
    corner_subtype: int = None

    def __post_init__(self):
        super().__post_init__()
        self.opening_defs = []
        self.corners = []

# bmWindow
    def add_window(self, offset=None, width=1, height=1, material=materials.AIR, material_subtype=0):
        """ Adds a window definition to the list of openings in a wall
            The window definition is a dictionary containing paramenters specifying
            the window dimensions and location relative to the wall origin """
        opening_def = {"length": width, "height": height, "material": material, "material_subtype": material_subtype}

        if offset is None:
            offset = (None, None)

        offset_x, offset_y = offset
        if offset_x is None:
            offset_x = (self.length - width) / 2
        if offset_y is None:
            offset_y = (self.height - height) / 2

        opening_def['offset'] = (offset_x, offset_y)

        self.opening_defs.append(opening_def)

    def add_door(self, offset=None, width=1, height=2, material=materials.AIR, material_subtype=0):
        opening_def = {"length": width, "height": height, "material": material, "material_subtype": material_subtype}

        if offset is None:
            offset = (None, None)

        offset_x, offset_y = offset
        if offset_x is None:
            offset_x = (self.length - width) / 2
        if offset_y is None:
            offset_y = 0

        opening_def["offset"] = (offset_x, offset_y)

        self.opening_defs.append(opening_def)

    def clear_openings(self):
        self.opening_defs.clear()

    def _calc_absolute_location(self, opening_def):
        """ Calculates the origin and rotation of an opening based on
            the origin of the parent Wall """
        offset_x, offset_y = opening_def["offset"]
        
        opening_def['origin'] = self.along(offset_x, offset_y)
        opening_def['phi'] = self.phi
        opening_def['theta'] = self.theta
        
    def draw(self):
        """ Draws a wall with corners (if specified) using MCRectangles"""
        
        super().draw()
        
        if self.corner_material:
            wall_def = {'name':f'{self.name}:Corner 1',
                        'origin':self.origin,
                        'length':1,
                        'phi':self.phi,
                        'theta':self.theta,
                        'height':self.height,
                        'material':self.corner_material,
                        'material_subtype':self.corner_subtype,
                       }
            
            # BUGBUG: Should this be an MCRectangle rather than a Wall?
            corner1 = Wall(**wall_def)
            self.corners.append(corner1)
            
            corner2 = corner1.copy(extend=True)
            corner2.origin = corner1.along(self.length-1,0)
            self.corners.append(corner2)

            for corner in self.corners:
                corner.draw()

        print(f"TT: {self.name} has {len(self.opening_defs)} openings")
        for opening_def in self.opening_defs:
            absolute_def = opening_def.copy()

            print(f"TT: Definition before {absolute_def}")
            self._calc_absolute_location(absolute_def)
            print(f"TT: Definition after  {absolute_def}")
            absolute_def['name'] = f"{self.name}:opening"
            del absolute_def['offset']
            
            print(f"New opening: {absolute_def}")
            new_opening = MCRectangle(**absolute_def)
            new_opening.debug = False
            new_opening.draw()

    # bmSetMaterials
    def set_materials(self, body_material, body_subtype, corner_material=None, corner_subtype=None):
        """ Sets the materials of the wall with optional different material
            for wall corners."""
#        BUGBUG: Document this --> print(type.mro(type((0,0))))
#        BUGBUG: Document this --> if hasattr(main, '__iter__'):

        self.material = body_material
        self.material_subtype = body_subtype
        
        if not corner_material is None:
            self.corner_material = corner_material
            self.corner_subtype = corner_subtype


# bmStory
class Story(MCComponent):
    def __init__(self, origin, width, height, depth, direction=Direction.NORTH):
        super().__init__("Story", origin)
        self.direction = direction
        self.ground_floor = True
        self.width = width
        self.height = height
        self.depth = depth
        self.direction = direction
        self.internal_wall_template = None
        self.external_wall_template = None
        self.walls = []
        self.floors = []

    def __repr__(self):
        msg = f"<{self.name}> origin:{self.origin}, "
        msg += f"width:{self.width}, "
        msg += f"height:{self.height}, "
        msg += f"depth:{self.depth}, "
        msg += f"direction:{self.direction}, "
        msg += f"# walls: {len(self.walls)}"
        return msg
    
    def copy(self):
        return copy.deepcopy(self)

    def shift(self, x, y, z):
        """Shifts the rectangle by an offset in each direction"""
        super().shift(x, y, z)
        for wall in self.walls:
            wall.shift(x, y, z)

        for floor in self.floors:
            floor.shift(x, y, z)


    def build_walls_from_perimeter(self):
        wall_lengths = [self.depth, self.width, self.depth]
        new_wall = self.external_wall_template.copy(extend=False)
        new_wall.origin = self.origin
        new_wall.length = self.width
        new_wall.height = self.height
        new_wall.theta = self.direction
        self.walls.append(new_wall)

        for wall_length in wall_lengths:
            new_wall = new_wall.copy(extend=True)
            new_wall.location = WallLocation.SIDE
            new_wall.clear_openings()
            new_wall.rotate_left()
            new_wall.length = wall_length
            self.walls.append(new_wall)
            
        self.walls[0].location = WallLocation.FRONT
        self.walls[2].location = WallLocation.BACK
        
    def add_openings(self, opening_size=0):
        front_wall = self.walls[0]
        if opening_size > 0:
            front_wall.clear_openings()
            if self.level == 1:
                self.walls[0].add_door(None, opening_size, 2*opening_size)
            else:
                self.walls[0].add_window(None, opening_size, opening_size)
                
            for index in range(1, len(self.walls)):
                wall = self.walls[index]
                wall.clear_openings()
                if (wall.location == WallLocation.SIDE):
                    wall.add_window(None, opening_size, opening_size)

    def build_floor_from_perimeter(self, material=None, subtype=None):
        if material is None:
            material = materials.WOOL
            subtype = materials.ORANGE
            
        floor = MCRectangle(self.origin, self.width, self.depth, self.direction)
        floor.material = material
        floor.material_subtype = subtype
        
        floor.is_tipped = True
        floor.shrink(1)
        floor.shift(0,-1,0)
        self.floors.append(floor)

    def draw(self):
        for wall in self.walls:
            wall.draw()
        for floor in self.floors:
            floor.draw()




class MCDebug():
    """Functions for setting up and testing MineCraft environment on Raspberry Pi.

    Methods that don't start with test_ (e.g. draw_ or clear_) use hard coded MineCraft APIs
    to draw structures, rather than mc_geometry code."""

    # Define some colored blocks for visual differentiation in tests
    blue_wool = (35, 11)
    red_wool = (35, 14)
    purple_wool = (35, 10)
    green_wool = (35, 13)
    yellow_wool = (35, 4)
    pink_wool = (35, 6)
    magenta_wool = (35, 2)
    light_blue_wool = (35, 3)
    orange_wool = (35, 1)
    white_wool = (35, 0)
    
    
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
    def clear_space(move_player=False):
        """Clears the air above and ground below a fixed space in MineCraft"""

        plane_size = 100
        space_above = 50
        ground_below = 5

        space_material = materials.AIR
        bedrock_material = materials.STONE
        ground_material = materials.DIRT

        if (MINECRAFT_EXISTS):
            MC.setBlocks(-plane_size/2, 0, -plane_size/2,
                         plane_size/2, space_above, plane_size/2, space_material)
            MC.setBlocks(-plane_size/2, -2, -plane_size/2, plane_size /
                         2, -ground_below-1, plane_size/2, bedrock_material)
            MC.setBlocks(-plane_size/2, -1, -plane_size/2,
                         plane_size/2, -1, plane_size/2, ground_material)

            # Put down blocks at 0,0,0, a red block point N and blue E
            MC.setBlock(0, 0, 0, block.GOLD_BLOCK.id, 0)
            MC.setBlock(0, 0, -1, *MCDebug.red_wool)
            MC.setBlock(1, 0, 0, *MCDebug.blue_wool)
            
            # Optionally move the player to a spot near the origin
            if move_player:
                MC.player.setPos(-5, 0, -5)
        
    def get_test_def(attributes = None, component_type=None):
        """Provide a set of test attributes"""
        
        if component_type is None:
            component_type = 'BASE'
        else:
            component_type = component_type.upper()
        
        base_def = {'name':'base_rect', 'phi':0, 'length':5, 'height':3}
        base_def['origin'] = (5, 0, 5)
        base_def['material'], base_def['material_subtype'] = MCDebug.yellow_wool
        base_def['theta'] = Direction.EAST
        
        if component_type == 'LOT':
            base_def['origin'] = (5, -1, 5)
            base_def['width'] = 20
            base_def['depth'] = 30
            base_def['direction'] = Direction.NORTH
            base_def['setbacks'] = (5,3,8,3)
            
        if component_type == 'STRUCTURE':
            base_def['width'] = 5
            base_def['depth'] = 5
            base_def['direction'] = Direction.NORTH
            base_def['story_height'] = 3

        if component_type == 'STORY':
            base_def['width'] = 5
            base_def['depth'] = 5
            base_def['height'] = 3

        if attributes is None:
            sub_def = base_def.copy()
        else:
            sub_def = {}
            for attribute in attributes:
                print(f"{attribute} = {base_def.get(attribute)}")
                sub_def[attribute] = base_def.get(attribute)

        if attributes is str:
            print("Attributes is a string")

        if len(sub_def) == 1:
            sub_def = list(sub_def.values())[0]
            
        return sub_def

    @staticmethod
    def test_mccomponent():
        """Tests the MineCraft component class (mccomponent)
        Succesful result is an orange block in the air to the SE of
        the TNT origin marker"""
        
        # Sets and prints the name and origin
        comp1 = MCComponent('C1', (1,2,3))
        print(comp1)
        
        # Creates a second instance and displays the debug flag
        comp2 = MCComponent('C2', (4,5,6))
        comp2.shift(1,1,1)
        print(comp2)
        print(f"Checking for debug flag: {comp2.debug}")
        
        # Creates a third instance, shifted by 1 in each direction
        comp3 = MCComponent('C3', (0,0,0))
        comp3.shift(1,1,1)
        comp3._draw_origin(*MCDebug.orange_wool)
        
    @staticmethod
    def test_mcvector():
        """Success is a magenta block in the air to the SE of the
            origin (5,3,5)"""
        vec1 = MCVector('Vec1', origin=(5,0,5), length=3, phi=0, theta=90)
        print(vec1)
        print(f"End point: {vec1.end_point}")
        endpoint = MCComponent('End point', vec1.end_point)
        endpoint._draw_origin(*MCDebug.magenta_wool)
        
        print(f"Testing for debug flag: {vec1.debug}")
        
    @staticmethod
    def test_mcrectangle():
        """Creates and manipulates several rectangles in MineCraft"""
        
        # Draw a rectangle 5 wide, 3 high pointing East made of TNT
        rec1 = MCRectangle('Rec1', (0,0,0), 5, 0, Direction.EAST, 3, materials.GRASS, 1)
        print(rec1)
        rec1.draw(materials.TNT, 1)
        
        # Draw a rectangle 5 wide, 3 high pointing North made of orange wool
        rec2 = rec1.copy(extend=False)
        rec2.name = 'Rec2'
        rec2.rotate_left()
        print(rec2)
        rec2.draw(*MCDebug.orange_wool)

        # Draw a flat rectangle on top of the orange rectangle
        # and set the origin to the opposite end (NorthWest)
        rec3 = rec1.copy(extend=False)
        rec3.name = 'Rec3'
        rec3.shift(0,3,0)
        rec3.is_tipped = True
        rec3.rotate_left()
        rec3.flip_origin(keep_direction=False)
        print(rec3)
        rec3.draw(*MCDebug.magenta_wool)

        # Rotate the first rectangle to point South
        rec1.rotate_right()
        rec1.flip_origin(keep_direction = False)
        rec1.draw(*MCDebug.blue_wool)
        print(rec1)
        
        # Reduce the first rectangle to 3 long x 1 high, then
        # redraw it in orange
        rec1.shrink(1)
        rec1.debug = False
        rec1.draw(*MCDebug.orange_wool)
                
    @staticmethod
    def test_mcrectangle_along():
        """ Tests the Rectangle.along method which returns the coordinate of
        a materials along a wall horizontally, vertically or both.
        A successful test will result in two perpendicular walls each with
        a materials of wool somewhere along the line."""
        
        # Get base set of attributes for tests
        attributes = ['name', 'origin', 'theta', 'phi', 'length', 'height']
        attributes.extend(['material', 'material_subtype'])
        wall_def = MCDebug.get_test_def(attributes)
        wall_def['theta'] = Direction.EAST
        
        wall1 = Wall(**wall_def)
        wall1.name = "Test Along East"
        wall1.set_materials(*MCDebug.light_blue_wool)
        wall1.draw()

        wall_def['theta'] = Direction.NORTH
        wall2 = Wall(**wall_def)
        wall2.name = "Test Along North"
        wall2.set_materials(*MCDebug.magenta_wool)
        wall2.draw()

        x1, y1, z1 = wall1.along(2)
        print(f"x1={x1}, y1={y1}, z1={z1}")
        MCComponent('Along1', (x1, y1, z1))._draw_origin(*MCDebug.blue_wool)

        x2, y2, z2 = wall2.along(2.5, 1.5)
        print(f"x2={x2}, y2={y2}, z2={z2}")
        MCComponent('Along2', (x2, y2, z2))._draw_origin(*MCDebug.blue_wool)

    @staticmethod
    def test_mcrectangle_vertical():
        """Creates and draws rectangles in a + pattern"""

        # Get base set of attributes for tests
        attributes = ['name', 'origin', 'theta', 'phi', 'length', 'height']
        attributes.extend(['material', 'material_subtype'])
        wall_def = MCDebug.get_test_def(attributes)
        wall_def['name'] = 'VRect1'

        # Vertical rectangles
        wall_def['theta'] = Direction.EAST
        rec1 = MCRectangle(**wall_def)
        rec1.material, rec1.material_subtype = MCDebug.blue_wool
        rec1.draw()

        wall_def['theta'] = Direction.WEST
        rec2 = MCRectangle(**wall_def)
        rec2.material, rec2.material_subtype = MCDebug.light_blue_wool
        rec2.draw()

        wall_def['theta'] = Direction.NORTH
        rec3 = MCRectangle(**wall_def)
        rec3.material, rec3.material_subtype = MCDebug.red_wool
        rec3.draw()

        wall_def['theta'] = Direction.SOUTH
        rec4 = MCRectangle(**wall_def)
        rec4.material_subtype = 6  # Pink
        rec4.draw()

    @staticmethod
    def test_mcrectangle_rotated():
        """ Exercises the rotate functionality on the Rectangle class
        The result should be 4 walls in a + pattern"""

        # Get a base definition for a 3x5 rectangle, pointing East
        attributes = ['name', 'origin', 'theta', 'phi', 'length', 'height']
        attributes.extend(['material', 'material_subtype'])
        rec_def = MCDebug.get_test_def(attributes)
        
        # Vertical rectangles
        rec_def['name'] = 'VRect_East'
        rec1 = MCRectangle(**rec_def)
        rec1.material, rec1.material_subtype = MCDebug.blue_wool
        rec1.draw()

        # Pointing South
        rec_def['name'] = 'VRect_South'
        rec1.material, rec1.material_subtype = MCDebug.light_blue_wool
        rec1.rotate_right()
        rec1.draw()

        # Pointing West
        rec_def['name'] = 'VRect_West'
        rec1.material, rec1.material_subtype = MCDebug.pink_wool
        rec1.rotate_right()
        rec1.draw()

        # Pointing North
        rec_def['name'] = 'VRect_North'
        rec1.material, rec1.material_subtype = MCDebug.red_wool
        rec1.rotate_right()
        rec1.draw()

    @staticmethod
    def test_mcrectangle_flat():
        """Creates and draws rectangles and their 'tipped' equivalent
        The rectangles should be 4 'L' shaped structures in a + pattern"""

        # Get a base definition for a 3x5 rectangle, pointing East
        attributes = ['name', 'origin', 'theta', 'phi', 'length', 'height']
        attributes.extend(['material', 'material_subtype'])
        rec_def = MCDebug.get_test_def(attributes)

        rec_def['name'] = 'FlatRect_East'
        rec1 = MCRectangle(**rec_def)
        rec1.material, rec1.material_subtype = MCDebug.blue_wool
        rec1.is_tipped = True
        rec1.draw()
        rec1.is_tipped = False
        rec1.draw()

        rec_def['name'] = 'FlatRect_South'
        rec_def['theta'] = Direction.SOUTH
        rec2 = MCRectangle(**rec_def)
        rec2.material, rec2.material_subtype = MCDebug.light_blue_wool
        rec2.is_tipped = True
        rec2.draw()
        rec2.is_tipped = False
        rec2.draw()

        rec_def['name'] = 'FlatRect_West'
        rec_def['theta'] = Direction.WEST
        rec3 = MCRectangle(**rec_def)
        rec3.material, rec3.material_subtype = MCDebug.pink_wool
        rec3.is_tipped = True
        rec3.draw()
        rec3.is_tipped = False
        rec3.draw()

        rec_def['name'] = 'FlatRect_North'
        rec_def['theta'] = Direction.NORTH
        rec4 = MCRectangle(**rec_def)
        rec4.material, rec4.material_subtype = MCDebug.red_wool
        rec4.is_tipped = True
        rec4.draw()
        rec4.is_tipped = False
        rec4.draw()

    @staticmethod
    def test_mcrectangle_copy():
        """Creates a rectangle and copies it to a second rectangle
        Result is two rectangles, the second offset the first by 5 spaces"""

        # Get a base definition for a 3x5 rectangle, pointing East
        attributes = ['name', 'origin', 'theta', 'phi', 'length', 'height']
        attributes.extend(['material', 'material_subtype'])
        rec_def = MCDebug.get_test_def(attributes)

        rec1 = MCRectangle(**rec_def)
        rec1.material, rec1.material_subtype = MCDebug.blue_wool
        rec1.draw()

        rec2 = rec1.copy(extend=True)
        rec2.material, rec2.material_subtype = MCDebug.light_blue_wool
        rec2.draw()

        rec3 = rec2.copy(extend=False)
        rec3.shift(0, 0, 2)
        rec3.material, rec3.material_subtype = MCDebug.magenta_wool
        rec3.draw()
        
    @staticmethod
    def test_mcrectangle_shrink():
        """Test the shrink method on a rectangle.
        Draws a large rectangle then a smaller rectangle inside"""
        
        # Get a base definition for a 3x5 rectangle, pointing East
        attributes = ['name', 'origin', 'theta', 'phi', 'length', 'height']
        attributes.extend(['material', 'material_subtype'])
        rec_def = MCDebug.get_test_def(attributes)

        rec_def['length'] = 8
        rec_def['height'] = 4

        rec1 = MCRectangle(**rec_def)
        rec1.material, rec1.material_subtype = MCDebug.magenta_wool
        rec1.is_tipped = False
        rec1.draw()
        
        rec2 = rec1.copy(extend=False)
        rec2.shrink(1)
        rec2.material, rec2.material_subtype = MCDebug.orange_wool
        rec2.draw()

    @staticmethod
    def test_mcrectangle_flip_origin():
        """Test the flip_origin method on a rectangle
        Success is two rectangles with the origins at opposite sides,
        on the bottom of the rectangle"""

        # Get a base definition for a 3x5 rectangle, pointing East
        attributes = ['name', 'origin', 'theta', 'phi', 'length', 'height']
        attributes.extend(['material', 'material_subtype'])
        rec_def = MCDebug.get_test_def(attributes)

        rec1 = MCRectangle(**rec_def)
        rec1.material, rec1.material_subtype = MCDebug.magenta_wool
        rec1.draw()

        rec2 = rec1.copy(extend=True)
        rec2.shift(3,0,0)
        rec2.flip_origin(keep_direction=False)
        rec2.draw()
        
    def test_mcrectangle_shift_parallel():
        """Tests the shift_parallel method on a rectangle
        Draws three rectangles, magenta in the center, blue and orange
        offset by 3 blocks in either direction"""
        
        # Get a base definition for a 3x5 rectangle, pointing East
        attributes = ['name', 'origin', 'theta', 'phi', 'length', 'height']
        attributes.extend(['material', 'material_subtype'])
        rec_def = MCDebug.get_test_def(attributes)

        rec_def['theta'] = Direction.EAST
        rec1 = MCRectangle(**rec_def)
        rec1.material, rec1.material_subtype = MCDebug.magenta_wool
        print(rec1)
        rec1.draw()
        
        rec2 = rec1.copy(extend=False)
        rec2.material, rec2.material_subtype = MCDebug.blue_wool
        rec2.shift_parallel(3)
        rec2.draw()

        rec3 = rec1.copy(extend=False)
        rec3.material, rec3.material_subtype = MCDebug.orange_wool
        rec3.shift_parallel(-3)
        rec3.draw()

    @staticmethod
    def test_lot():
        """ Tests the creation of a job site by clearing a space to build on """

        # Get a base definition for a lot
        attributes = ['name', 'origin', 'width', 'depth']
        # attributes.extend(['material', 'material_subtype'])
        lot_def = MCDebug.get_test_def(attributes, 'LOT')
        lot_def['width'] = 5
        lot_def['depth'] = 8
        
        # Draw a lot with wool for the lot, stone for the ground, and
        # grass for the sky
        site = Lot(**lot_def)
        site.add_surface()
        print(f"Lot: {site}")
        site.clear(materials.WOOL, materials.BEDROCK, materials.GRASS)
        print(f"First site: {site}")
 
        # Build a lot 10 across and 20 deep along the East axis
        lot_def['direction'] = Direction.EAST
        lot_def['width'] = 10
        lot_def['depth'] = 20
        site2 = Lot(**lot_def)
        site2.add_surface()
        site2.shift_parallel(site2.width)
        site2.clear(materials.GRASS, materials.BEDROCK, materials.AIR)

        # Set the setbacks
        site2.set_setbacks(5,2)
        print(f"Setbacks are: {site2.setbacks} (front, left, back, right)")
        
    @staticmethod
    def test_lot_get_next_structure_origin():
        # Get a base definition for a lot
        attributes = ['name', 'origin', 'direction', 'width', 'depth']
        lot_def = MCDebug.get_test_def(attributes, 'LOT')
        print(f"Lot definition: {lot_def}")
        
        site = Lot(**lot_def)
        site.add_surface()
        site.setbacks = (3,5,1,1)
        site.clear()
        print(site)
        
        new_origin = site.get_next_structure_origin()
        print(f"Next origin is: {new_origin}")
        
        block = MCComponent(name="block", origin=new_origin)
        block._draw_origin()
        
    @staticmethod
    def test_wall():
        """ Tests the basic methods of drawing a wall """

        # Get a base definition for a 3x5 rectangle, pointing East
        attributes = ['name', 'origin', 'theta', 'phi', 'length', 'height']
        attributes.extend(['material', 'material_subtype'])
        wall_def = MCDebug.get_test_def(attributes)
            
        """ Draw a single wall in 4 directions (North = Red) """
        directions = [Direction.NORTH, Direction.SOUTH, Direction.EAST, Direction.WEST]
        colors = [MCDebug.red_wool, MCDebug.orange_wool, MCDebug.blue_wool, MCDebug.light_blue_wool]
        
        for i in range(len(directions)):
            wall_def['name'] = f"Plus_{directions[i]}"
            wall_def['theta'] = directions[i]
            wall_def['material'], wall_def['material_subtype'] = colors[i]
            wall = Wall(**wall_def)
            wall.flip_origin(keep_direction = False)
            print(wall)
            wall.draw()
        
        """ Draws 4 walls with the rotate_left method """
        wall_def['name'] = f'Wall_{Direction.NORTH}'
        wall_def['origin'] = shift(MCDebug.test_origin, 15, 0, 0)
        wall_def['theta'] = Direction.NORTH
        wall_def['material'], wall_def['material_subtype'] = MCDebug.white_wool
        wall = Wall(**wall_def)
        wall.draw()
        
        for i in range(3):
            wall = wall.copy(extend=True)
            wall.set_materials(*colors[i])
            wall.rotate_left()
            wall.draw()

        """ Draws 4 walls with the rotate_right method """
        wall_def['name'] = f'Wall_{Direction.NORTH}'
        wall_def['origin'] = shift(MCDebug.test_origin, 20, 0, 0)
        wall_def['theta'] = Direction.NORTH
        wall_def['material'], wall_def['material_subtype'] = MCDebug.white_wool
        wall = Wall(**wall_def)
        wall.draw()
        
        for i in range(3):
            wall = wall.copy(extend=True)
            wall.set_materials(*colors[i])
            wall.rotate_right()
            wall.draw()
            
    @staticmethod
    def test_wall_corners():
        """ Draws walls with different corners for the main wall and corners """

        # Get a base definition for a 3x5 rectangle, pointing East
        attributes = ['name', 'origin', 'theta', 'phi', 'length', 'height']
        attributes.extend(['material', 'material_subtype'])
        wall_def = MCDebug.get_test_def(attributes)

        wall_def['name'] = f'Wall_{Direction.NORTH}'
        wall_def['theta'] = Direction.NORTH
        wall1 = Wall(**wall_def)
        wall1.set_materials(*MCDebug.blue_wool, *MCDebug.orange_wool)
        print(wall1)
        wall1.draw()

        wall2 = wall1.copy(extend=False)
        wall2.set_materials(*MCDebug.magenta_wool, *MCDebug.light_blue_wool)
        wall2.shift_parallel(-8)
        wall2.rotate_left()
        wall2.draw()
#bm1
    @staticmethod
    def test_wall_openings():
        """ Tests adding windows and doors to a wall """
        
        # Get a base definition for a 3x5 rectangle, pointing East
        attributes = ['name', 'origin', 'theta', 'phi', 'length', 'height']
        attributes.extend(['material', 'material_subtype'])
        wall_def = MCDebug.get_test_def(attributes)

        wall1 = Wall(**wall_def)
        wall1.set_materials((materials.WOOD_PLANKS, 0), (materials.WOOD, 0))
        wall1.add_window(None, 1, 1, materials.TNT, 1)
        wall1.draw()

        wall2 = wall1.copy(extend=True)
        wall2.rotate_left()
        wall2.clear_openings()
        wall2.draw()

        wall3 = wall2.copy(extend=True)
        wall3.add_window()
        wall3.rotate_left()
        wall3.draw()

        wall4 = wall3.copy(extend=True)
        wall4.rotate_left()
        wall4.clear_openings()
        wall4.add_door(None, 1, 2, materials.AIR, 0)
        wall4.draw()

    @staticmethod
    def test_wall_on_lot():
        """ Sets the origin of a wall based on an offset from the lot corner """
        
        # Get a base definition for a 3x5 rectangle, pointing East
        attributes = ['name', 'origin', 'theta', 'phi', 'length', 'height']
        attributes.extend(['material', 'material_subtype'])
        lot_def = MCDebug.get_test_def(attributes, 'LOT')
        print(lot_def)
        site = Lot(**lot_def)
        site.clear()

        """
        site.name = "Job site"
        site.material = materials.GRASS
        site.clear()
        
        wall_def = MCDebug.get_test_def()
        wall_def['origin'] = site.offset_origin(2,3)
        wall = Wall(**wall_def)
        wall.set_materials(*MCDebug.light_blue_wool)
        wall.draw()
        """
        
    @staticmethod
    def test_structure():
        # Get a base definition for a structure pointing East
        attributes = ['name', 'origin', "width", "depth", "direction", "story_height"]
        structure_def = MCDebug.get_test_def(attributes, 'structure')
        print(structure_def)
        building = Structure(**structure_def)
        building.add_foundation()
        building.draw()

    
    @staticmethod
    def test_stories():
        site_set_back = (2, 4)
        
        story_width = 11
        story_height = 6
        story_depth = 9
        lot_direction = Direction.NORTH

        site = Lot(origin=(0, -1, 0), width=20, depth=50, direction=lot_direction)
        site.name = "Pandaville"
        site.material = materials.GRASS
        site.clear()
        story_origin = site.offset_origin(*site_set_back)

        wall_template = Wall(story_origin, 1, 1)
        wall_template.set_materials(materials.WOOD_PLANKS, materials.WOOD)

        first_floor = Story(story_origin, story_width,
                            story_height, story_depth)
        first_floor.level = 1
        first_floor.external_wall_template = wall_template
        first_floor.direction = lot_direction
        first_floor.build_walls_from_perimeter()
        first_floor.add_openings(opening_size=1)
        first_floor.build_floor_from_perimeter(materials.COBBLESTONE)
        first_floor.draw()

        second_floor = first_floor.copy()
        second_floor.level = 2
        second_floor.add_openings(opening_size=1)
        second_floor.shift(0,story_height,0)
        second_floor.draw()
                
    @staticmethod
    def build_outline():
        """Draws a square shaped structure from 4 walls drawn by making
        3 copies of the original wall, and rotating them left"""
        # Get a base definition for a 3x5 rectangle, pointing East
        rec_def = MCDebug.get_test_def()

        rec = MCRectangle(**rec_def)
        rec.material, rec.material_subtype = MCDebug.magenta_wool
        rec.draw()

        for i in range(3):
            rec = rec.copy(extend=True)
            rec.rotate_left()
            rec.draw()        

    def test_build_houses():
        site = Lot(origin=(0, -1, 0), across=20, depth=50, direction=Direction.NORTH)
        site.name = "Job site"
        print(site)
        site.material = materials.GRASS
        site.clear()
        

def main():
    """Main function which is run when the program is run standalone"""
    dbg_print(f"Debug level: {LOG_LEVEL}", 0)
    MCDebug.clear_space(False)   # Low-level clear using setBlocks
#    MCDebug.test_mccomponent()
#    MCDebug.test_mcvector()
#    MCDebug.test_mcrectangle()
#    MCDebug.test_mcrectangle_along()
#    MCDebug.test_mcrectangle_vertical()
#    MCDebug.test_mcrectangle_rotated()
#    MCDebug.test_mcrectangle_flat()
#    MCDebug.test_mcrectangle_copy()
#    MCDebug.test_mcrectangle_shrink()
#    MCDebug.test_mcrectangle_flip_origin()
#    MCDebug.test_mcrectangle_shift_parallel()
#    MCDebug.test_lot()
    MCDebug.test_lot_get_next_structure_origin()
#    MCDebug.test_wall()
#    MCDebug.test_wall_corners()
#    MCDebug.test_wall_openings()
#    MCDebug.test_wall_on_lot()
#    MCDebug.test_stories()
#    MCDebug.test_structure()
#    MCDebug.build_outline()

if __name__ == '__main__':
    main()
else:
    print('Running as a module')
