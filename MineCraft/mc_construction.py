'''
Library for building houses in MineCraft Pi

A build consists of several components (lot, house, floors, walls, ...)
Each component inherits from the Component class which provides a
base implementation for __init__ and __repr__

A component is initialized with an instance of a "definition" object
for that component type (e.g. WallDefinition for Wall).

Setting attributes (e.g. origin) for a child component should occur
in the add_<component> method of the parent class

Order of operations for setting attributes:
- Set default values (or None) in the __init__ of the definition class
- Override default values to specific values on the definition instance
- Set no overrides nor defaults in the __init__ for the component
    - Use only the values from the definition class
- For components created by a parent, use an add_<component> method on the parent
    - Set values from the parent (e.g. direction, wall material) on the
      template in the add_<component> method before creating the instance

To do:


'''
from enum import Enum, IntEnum, unique
from mcpi.minecraft import Minecraft
from mcpi import block
from mcpi.vec3 import Vec3
import mcpi
import math
import time
from mc_test_data import *

print(mcpi)
mc = Minecraft.create()


@unique
class Plane(Enum):
    ''' Defines friendly names for each of the 3 dimensional planes '''
    XY = 1  # East/West
    XZ = 2  # Up/Down
    YZ = 3  # South/North


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
    Flat = -1
    Left = 1000
    Right = 1001
    Flip = 1002

    def rotate_left(self):
        ''' Returns the direction at 90 degrees counter clockwise '''
        return Direction(self._normalize_angle(self.value + 90))

    def rotate_right(self):
        ''' Returns the direction at 90 degrees clockwise '''
        return Direction(self._normalize_angle(self.value - 90))

    def flip(self):
        ''' Returns the direction at 180 degrees from the current direction '''
        return Direction(self._normalize_angle(self.value - 180))

    def _normalize_angle(self, angle):
        ''' Normalizes an angle in degrees to a value between 0 and 360 '''
        while angle <= 0:
            angle += 360
        while angle >= 360:
            angle -= 360
        return angle


@unique
class WallType(IntEnum):
    ''' Specifies whether a wall is an internal or external wall '''
    Exterior = 1
    Interior = 2


@unique
class WallLocation(IntEnum):
    ''' Specifies whether a wall is at the front, back or side of a story '''
    Front = 1
    Back = 2
    Side = 3


class ComponentDefinition():
    '''
    Provides base class with init that pulls attributes from a template,
    and enumerates the attributes through __repr__
    '''

    def __init__(self, attribute_list=None, template=None):
        # Copy exclusively the specified attributes from the template
        # If a specified attribute doesn't exist on the template, the
        # attribute is initialized to None

        # BUGBUG: Make common_attributes a NV pair with default values
        common_attributes = ['name']

        if attribute_list is None:
            attribute_list = []

        attribute_list += common_attributes
        for attribute in attribute_list:
            setattr(self, attribute, getattr(template, attribute, None))

    def __repr__(self):
        msg = f"{type(self).__name__}\n"
        for attribute in self.__dict__:
            msg += f"  {attribute}:{getattr(self, attribute, '<undefined>')}\n"
        return msg


class Component():
    '''
    Provides a base class implementation of __repr__ to enumerage attributes
    '''

    def _copy_definition(self, definition):
        for attribute in definition.__dict__:
            print(
                f"COPYDEFINITION: {attribute} = {getattr(definition, attribute, None)}")
            setattr(self, attribute, getattr(definition, attribute, None))

    def __repr__(self):
        msg = f"{type(self).__name__}\n"
        for attribute in self.__dict__:
            msg += f"  {attribute}:{getattr(self, attribute, '<undefined>')}\n"
        return msg

# BM_1


class RectangleDefinition(ComponentDefinition):
    ''' Defines the attributes for a rectangle '''

    def __init__(self, template=None):
        attributes = ['length', 'height', 'origin', 'xz_angle', 'xy_angle']
        super().__init__(attributes, template)

        if self.xy_angle is None:
            self.xy_angle = 0


class Rectangle(Component):
    ''' Definition of rectangular structure for MineCraft Pi '''

    def __init__(self, definition):
        # BUGBUG: Convert this to use a component definition to be consistent
        super()._copy_definition(definition)
        self._calc_opposite_corners()
        print(f"REC_INIT: origin: {self.origin}, opposite: {self.opposite}")

    def _calc_opposite_corners(self):
        ''' Calculates the opposite corner on the rectange based on origin, length and angle.
            In MineCraft space, the axes are different than convention, so:
            x = East/West
            y = Altitude
            z = South/North

            theta = angle between vertical and horizontal planes, xy_angle (0 = vertical)
            phi = angle around the horizontal plane, xz_angle (0 = East?)
            r = the length of the radius (rectangle)

            x = r * sin(theta) * cos(phi)
            y = r * cos(theta)
            z = r * sin(theta) * sin(phi)

        '''
        theta = math.radians(self.xz_angle)
        opp_sin = round(math.sin(theta))
        opp_cos = round(math.cos(theta))

        print(
            f"Calculating corners at xz_angle = {self.xz_angle} ({self.tipped})")

        opp_x = round((self.length-1) * opp_sin, 1)
        opp_y = self.height-1
        opp_z = round((self.length-1) * opp_cos, 1)

        # The rectangle is always tipped in the positive direction
        # BUGBUG: This is cheating.  Use the spherical coordinates
        if self.tipped:
            if (opp_sin == 0) and (opp_cos == -1):  # 180 degrees
                self.opposite = self.origin + Vec3(opp_y, opp_x, opp_z)
            elif (opp_sin == 0) and (opp_cos == 1):  # 0 degrees
                self.opposite = self.origin + Vec3(opp_y, opp_x, opp_z)
            elif (opp_sin == 1) and (opp_cos == 0):  # 90 degrees
                self.opposite = self.origin + Vec3(opp_x, opp_z, opp_y)
            elif (opp_sin == -1) and (opp_cos == 0):  # 270 degrees
                self.opposite = self.origin + Vec3(opp_x, opp_z, opp_y)
        else:
            self.opposite = self.origin + Vec3(opp_x, opp_y, opp_z)

    def set_direction(self, direction):
        ''' Sets the direction of a rectangle (e.g. Direction.North) '''
        self.xz_angle = int(direction)
        self._calc_opposite_corners()

    def set_length(self, length):
        ''' Sets the length attribute and recalculates the opposite corner '''
        self.length = length
        self._calc_opposite_corners()

    def rotate(self, angle=0):
        ''' Stubbed out to rotate a rectangle about an axis '''
        pass

    def rotateLeft(self):
        ''' Rotates a rectangle counter-clockwise in the x-z (vertical) plane '''
        # BUGBUG: Convert these to the methods on the Direction class
        self.xz_angle += 90
        self._calc_opposite_corners()

    def rotateRight(self):
        ''' Rotates a rectangle clockwise in the x-z (vertical) plane '''
        # BUGBUG: Convert these to the methods on the Direction class
        self.xz_angle -= 90
        self._calc_opposite_corners()

    def flip(self):
        ''' Rotates a rectangle to face the opposite direction in the x-z (vertical) plane '''
        # BUGBUG: Convert these to the methods on the Direction class
        self.xz_angle -= 180
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
        # BUGBUG: Make this a property
        midpoint_x = (self.opposite.x + self.origin.x)/2
        midpoint_y = (self.opposite.y + self.origin.y)/2
        midpoint_z = (self.opposite.z + self.origin.z)/2
        msg = f"Calculated midpoint from {self.origin} to {self.opposite}"
        msg += f"as {midpoint_x}, {midpoint_y}, {midpoint_z}"
        print(msg)
        return Vec3(midpoint_x, midpoint_y, midpoint_z)

    def along(self, distance):
        '''
            Returns the x,y,z coordinate of a point along the bottom of a
            rectangle in absolute coordinates
            The point can be beyond the end-points of the rectangle
        '''
        along_x = round(
            (distance-1) * math.sin((math.pi/180)*self.xz_angle), 1)
        along_z = round(
            (distance-1) * math.cos((math.pi/180)*self.xz_angle), 1)
        return self.origin + Vec3(along_x, 0, along_z)

    def shift(self, offset_x=0, offset_y=0, offset_z=0):
        ''' Moves the rectangle in the specified x, y, and z directions '''
        self.origin += Vec3(offset_x, offset_y, offset_z)
        self._calc_opposite_corners()

    def tip(self):
        ''' Tips a rectangle to the East or South horizontal plane '''
        self.xy_angle = 90
        self._calc_opposite_corners()

    def draw(self, material, subtype=0):
        '''
            Draws the rectangle in MineCraft space
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


class FloorDefinition(ComponentDefinition):
    '''
        Class to define the attributes of a Floor object

        A floor has:
            width - The width of the lot (across the screen)
            depth - The depth of the lot (into the screen)
            thickness - Distance (into the ground)
            origin - Front corner of the lot
            xz_angle - Rotation of the lot (for direction)
            material/submaterial
    '''

    def __init__(self, template=None):
        # Copy attributes from the template
        attributes = ['origin', 'width', 'depth',
                      'height', 'thickness', 'xz_angle']
        attributes += ['base_material',
                       'base_material_subtype', 'tipped', 'length']
        super().__init__(attributes, template)

        # Default the origin to the space under the player
        if self.origin is None:
            self.origin = mc.player.getPos() - Vec3(0, 1, 0)


class Floor(Component):
    ''' Base class to represent the horizontal plane for a floor, site, or foundation '''

    def __init__(self, floor_definition):
        self._copy_definition(floor_definition)

        floor = Rectangle(floor_definition)
        floor.tip()

#        self.floor = floor

    def _draw_origin(self, material):
        origin_x, origin_y, origin_z = self.origin
        mc.setBlock(origin_x, origin_y, origin_z, material)
        print(f"Floor origin is at {origin_x},{origin_y},{origin_z}")

    def clear(self, floor_material=None, floor_material_subtype=None):
        if floor_material is None:
            floor_material = self.base_material
            floor_material_subtype = self.base_material_subtype

        x1, y1, z1 = self.origin
        x2, y2, z2 = self.origin + \
            Vec3(self.depth-1, -self.thickness+1, self.width-1)

        mc.setBlocks(x1, y1, z1, x2, y2, z2,
                     floor_material, floor_material_subtype)

        # Clear out the space above the area of the horizontal plane
        if self.height > 1:
            mc.setBlocks(x1, y1+1, z1, x2, y1+self.height-1, z2, block.AIR.id)


class Site(Floor):
    # BUGBUG: Review how a site_definition can be used here.  Is it a FloorDefinition?
    def __init__(self, site_definition):
        self.structures = []
        super().__init__(site_definition)

    def add_structure(self, structure_definition):
        ''' Add a structure (e.g. house) to the site '''
        # BUGBUG:  Make sure this is consistent with other Components
        if structure_definition.origin is None:
            structure_definition.origin = self.origin + \
                Vec3(self.setback, 0, self.setback)
        house = Structure(structure_definition)
        self.structures.append(house)
        return house

# BM_1


class WallDefinition(ComponentDefinition):
    ''' Class to define the attributes of a wall object '''

    def __init__(self, template=None):
        attributes = ["origin", "length", "height", "xz_angle", "location"]

        super().__init__(attributes, template)

        # Default the origin to the space under the player
        if self.origin is None:
            self.origin = mc.player.getPos() - Vec3(0, 1, 0)
            print(f"WALLDEFINITION: Defaulting origin to {self.origin}")

    def _set_materials(self):
        if self.type == WallType.Exterior:
            self.material = block.GRASS.id  # parent_story.parent_house.exterior_wall_material
            self.material_subtype = 1  # parent_story.parent_house.exterior_wall_material_subtype
            # parent_story.parent_house.exterior_corner_material
            self.corner_material = block.TNT.id
            self.corner_subtype = 1  # parent_story.parent_house.exterior_wall_corner_subtype
        elif self.type == WallType.Interior:
            self.material = block.DIRT.id  # parent_story.parent_house.exterior_wall_material
            self.material_subtype = 1  # parent_story.parent_house.exterior_wall_material_subtype
            # parent_story.parent_house.exterior_corner_material
            self.corner_material = block.STONE.id
            self.corner_subtype = 1  # parent_story.parent_house.exterior_wall_corner_subtype
        else:
            print(f"EXCEPTION: No wall type set")

    def _set_angle(self, xz_angle=None):
        ''' Sets the angle of the wall to the specified value, or the 'facing' property if it exists '''
        if xz_angle is None:
            # xz_angle = self.parent_story._calc_angle_from_facing()
            pass
        self.xz_angle = xz_angle


class Wall(Rectangle):
    ''' The parent of a Wall should be a Story object '''

    def __init__(self, wall_definition):
        # length, height, origin=None, xz_angle=0):
        self._copy_definition(wall_definition)
#        wd = wall_definition
        super().__init__(self.length, self.height, self.origin, self.xz_angle)
#        self.wall_definition = wd
        self.doors = []
        self.windows = []
#        self.wall_material = block.TNT.id
#        self.wall_material_subtype = 1
#        self.corner_material = block.WOOL.id
#        self.corner_subtype = 1
#        self.wall_type = WallType.Exterior

    def add_door(self, position=None):
        ''' Position is relative to the origin of the parent wall '''

        # If a position is not specified for the door, use the midpoint at the bottom of the wall
        if position is None:
            position = (self.length + 1) / 2

        width = 1
        height = 2
        origin = self.along(position)
        xz_angle = self.xz_angle
        door = Opening(self, position, 1, width, height)
        door.material = block.GRASS.id
        door.material_subtype = 0
        self.position = position
        self.doors.append(door)

    def add_window(self, position_x=None, position_y=None):
        ''' Position is relative to the origin of the parent wall '''

        # If a position is not specified for the window, use the midpoint
        rel_x, rel_y, rel_z = self.midpoint() - self.origin
        if position_x is None:
            position_x = (self.length + 1) / 2
        if position_y is None:
            position_y = (self.height + 1) / 2
        # glurb
        width = 1
        height = 1
        xz_angle = self.xz_angle
        window = Opening(self, position_x, position_y, width, height)
        window.material = block.AIR.id
        window.material_subtype = 0
        self.windows.append(window)

    def set_wall_material(self, material, subtype=0):
        ''' Sets the attributes for wall material '''
        self.wall_material = material
        self.wall_material_subtype = subtype

    def set_corner_material(self, material, subtype=0):
        ''' Sets the attributes for corner material '''
        self.corner_material = material
        self.corner_material_subtype = subtype

    def _draw(self, material=None, subtype=1):
        #        wd = self.wall_definition
        if material is None:
            material = self.material
            subtype = self.material_subtype
        super()._draw(material, subtype)
        if not (getattr(self, "corner_material", None) is None):
            ll_x, ll_y, ll_z = self.origin
            ur_x, ur_y, ur_z = self.opposite

            mc.setBlocks(ll_x, ll_y, ll_z, ll_x, ur_y, ll_z,
                         self.corner_material, self.corner_material_subtype)
            mc.setBlocks(ur_x, ur_y, ur_z, ur_x, ll_y, ur_z,
                         self.corner_material, self.corner_material_subtype)
        for door in self.doors:
            door._draw(block.AIR.id)

        for window in self.windows:
            window._draw(block.AIR.id)

    def clone(self):
        new_wall = Wall(self.length, self.height,
                        self.origin.clone(), self.xz_angle)
        new_wall.set_wall_material(
            self.wall_material, self.wall_material_subtype)
        new_wall.set_cornerparent_wall_material(
            self.corner_material, self.corner_material_subtype)
        return new_wall


class OpeningDefinition(ComponentDefinition):
    # BUGBUG: Should this inherit from a RectangleDefinition?
    def __init__(self, template):
        attributes = ["parent_wall", "relative_x",
                      "relative_y", "width", "height"]
        attributes += ["material", "subtype"]
        super().init(attributes, template)

        if self.material is None:
            self.material = block.AIR.id


class Opening(Rectangle):
    '''
    A rectangle object to represent a door, window or other space in a wall
    relative_x is distance relative to the origin of the parent wall (1 is left side)
    relative_y is distance relative to the bottom of the wall (1 is bottom)
    '''

    # BUGBUG: Use the component parent methods
    def __init__(self, definition):
        super()._copy_definition(definition)

        if not isinstance(parent_wall, Wall):
            return None  # BUGBUG:  Should be an exception

        origin = self.absolute_origin
        xz_angle = self.parent_wall.xz_angle
        super().__init__(definition)

        self.material = block.AIR.id

        self._calc_opposite_corners()

    @property
    def absolute_origin(self):
        return self.parent_wall.along(self.relative_x) + Vec3(0, self.relative_y-1)

    def _draw(self, material=None, subtype=0):
        # BUGBUG: Remove the overridden function.  Rely on the parent function.
        if material is None:
            material = self.material
            subtype = self.material_subtype
        super()._draw(material, subtype)


class StoryDefinition(ComponentDefinition):
    # BM_2
    ''' Class to define the attributes of a Story object '''
    # BUGBUG: Make sure all ComponentDefinitions follow this pattern.
    # BUGBUG:      Declare attributes to initialize, call super __init__
    # BUGBUG:        to assign values from template

    def __init__(self, template=None):
        attributes = ['origin', 'width', 'depth', 'height', 'facing']
        attributes += ['exterior_wall_def', 'interior_wall_def']
        super().__init__(attributes, template)


class Story(Component):
    ''' Class to represent a story in a structure '''

    def __init__(self, story_definition):
        # BUGBUG: Call the _copy_definition class and get rid of the local story_definition
        # BUGBUG: Make sure all Component sub-classes call _copy_definition
        # BUGBUG: Call __init__ on parent
        # BUGBUG: Make sure all Component sub-classes call __init__ on parent
        self.story_definition = story_definition
        self.walls = []
        self.floor = None  # Ground class

    def add_wall(self, wall_definition):
        ''' Creates a wall using a WallDefinition as a template, and adds it to the collection '''
        # BUGBUG: Make sure all add_<component> methods set attributes from parent, update the
        #       component definition instance, instantiate the component and add to an arrray
        if wall_definition.origin is None:
            if len(self.walls) == 0:
                wall_definition.origin = self.story_definition.origin
            else:
                print(f"Getting origin from previous wall")

        wall = Wall(wall_definition)
        self.walls.append(wall)
        return wall

    def build_rectangle(self):
        ''' Creates a story with 4 exterior walls of prescribed length '''
        walls = []
        wall_lengths = [self.width, self.depth, self.width, self.depth]

        wall = self.exterior_wall_def

        wall.windows.clear()
        wall.doors.clear()
        wall.set_length(wall_lengths[0])
        wall.add_door()
        walls.append(wall)

        for index in range(2, 5):
            wall = wall.clone()
            wall.name = f"Wall{index} {id(wall)}"
            wall.flip_origin()
            wall.rotateRight()
            wall.set_length(wall_lengths[index-1])
            wall.add_window()
            walls.append(wall)

        self.walls = walls

    def _draw_origin(self, material, material_subtype=1):
        x, y, z = self.story_definition.origin
        mc.setBlock(x, y, z, material, material_subtype)


class StructureDefinition(ComponentDefinition):
    ''' Class to define the attributes of a Structure object '''

    def __init__(self, template=None):
        # Copy attributes from the template
        # BUGBUG: Make exterior and interior wall definitions consistent with Story
        # BUGBUG: Make foundation an instance of a Floor class
        attributes = ['origin', 'width', 'depth', 'story_height', 'facing']
        attributes += ['exterior_wall_material', 'exterior_wall_subtype']
        attributes += ['interior_wall_material', 'interior_wall_subtype']
        attributes += ['foundation_material', 'foundation_subtype']
        super().__init__(attributes, template)

        # Default the origin to the space under the player
        # BUGBUG: Document defaults set by other component definition classes
        # BUGBUG: Is this a best practice?  If so, confirm other definition classes
        if self.origin is None:
            self.origin = mc.player.getPos() - Vec3(0, 1, 0)
# BM_3


class Structure(Component):
    ''' Class to represent a Structure (e.g. a house) on a site '''

    def __init__(self, structure_definition):
        # BUGBUG: Fix to call _copy_definition and __init__ for parent
        sd = structure_definition

        self.structure_definition = sd
        self.roof = None
        self.stories = []
        self.foundation = None

    def add_foundation(self, material, material_subtype):
        # BUGBUG: Make this consistent with add_wall and/or add_story
        sd = self.structure_definition

        # Create the foundation of the structure
        foundation_def = FloorDefinition()
        foundation_def.origin = sd.origin
        foundation_def.width = sd.width
        foundation_def.depth = sd.depth
        foundation_def.height = 1
        foundation_def.thickness = 2
        foundation_def.xz_angle = sd.xz_angle
        foundation_def.base_material = material
        foundation_def.base_material_subtype = material_subtype

        self.foundation = Floor(foundation_def)

    def add_story(self, story_definition):
        print("STRUCTURE: add_story")
        if story_definition.origin is None:
            story_definition.origin = self.structure_definition.origin + \
                Vec3(0, 1, 0)
        story = Story(story_definition)
        self.stories.append(story)
        return story


def bump_player():
    ''' Offsets player position by 1 in all directions '''
    player_x, player_y, player_z = mc.player.getPos()
    mc.player.setPos(player_x+1, player_y+1, player_z+1)


def debug_clear_space():
    x1 = -(TEST_SITE_E_BOUND * TEST_WORLD_RATIO)
    y1 = -(TEST_SITE_DEPTH)
    z1 = -(TEST_SITE_S_BOUND * TEST_WORLD_RATIO)
    x2 = TEST_SITE_E_BOUND * TEST_WORLD_RATIO
    y2 = TEST_SITE_DEPTH * 10
    z2 = TEST_SITE_S_BOUND * TEST_WORLD_RATIO
    mc.setBlocks(x1, y1, z1, x2, TEST_ORIGIN_Y, z2, block.GRASS.id)
    mc.setBlocks(x1, TEST_ORIGIN_Y, z1,
                 x2, y2, z2, block.AIR.id)
    mc.player.setPos(TEST_ORIGIN_X - 5, TEST_ORIGIN_Y, TEST_ORIGIN_Z - 5)


def test_rectangle_directions():
    mc.postToChat("Testing rectangle directions")
    mc.postToChat("Confirm 4 rectangles with red pointing North")

    rectangle_basics = [
        #        {"direction": Direction.South, "material": block.WOOL.id, "subtype": TEST_RED},
        {"direction": Direction.North, "material": block.WOOL.id, "subtype": TEST_BLUE},
        #        {"direction": Direction.East,  "material": block.WOOL.id, "subtype": TEST_BLUE},
        #        {"direction": Direction.West,  "material": block.WOOL.id, "subtype": TEST_BLUE},
    ]

    o_x = TEST_ORIGIN_X
    o_y = TEST_ORIGIN_Y
    o_z = TEST_ORIGIN_Z

    for _definition in rectangle_basics:
        rectangle_definition = RectangleDefinition()
        rectangle_definition.origin = Vec3(o_x, o_y, o_z)
        rectangle_definition.length = TEST_WALL_LENGTH
        rectangle_definition.height = TEST_WALL_HEIGHT
        rectangle_definition.xz_angle = _definition["direction"]
        rec = Rectangle(rectangle_definition)
        rec.draw(_definition["material"], _definition["subtype"])
        rec._draw_origin()
        print(rec)


def test_tipped_rectangles():
    mc.postToChat("Testing tipped rectangles")
    mc.postToChat("Confirm 4 'couch' structures.  2 South, 2 East")

    rectangle_basics = [
        {"direction": Direction.South, "material": block.WOOL.id, "subtype": TEST_RED},
        {"direction": Direction.North, "material": block.WOOL.id, "subtype": TEST_RED},
        {"direction": Direction.East,  "material": block.WOOL.id, "subtype": TEST_BLUE},
        {"direction": Direction.West,  "material": block.WOOL.id, "subtype": TEST_BLUE},
    ]
    origin_x = TEST_ORIGIN_X
    origin_y = TEST_ORIGIN_Y
    origin_z = TEST_ORIGIN_Z
    for _definition in rectangle_basics:
        rectangle_definition = RectangleDefinition()
        rectangle_definition.origin = Vec3(origin_x, origin_y, origin_z)
        rectangle_definition.length = TEST_WALL_LENGTH
        rectangle_definition.height = TEST_WALL_HEIGHT
        rectangle_definition.xz_angle = _definition["direction"]
        rec_vertical = Rectangle(rectangle_definition)
        rec_tipped = Rectangle(rectangle_definition)
        rec_tipped.tip()
        rec_vertical.draw(_definition["material"], _definition["subtype"])
        rec_vertical._draw_origin()
        rec_tipped.draw(_definition["material"], _definition["subtype"])
        rec_tipped._draw_origin()
        print(rec_tipped)

        origin_z -= 10

# bm_tests


def test_rectangle_rotate():
    mc.postToChat("Testing rectangle rotate methods")

    rectangle_basics = [
        {"direction": Direction.South, "material": block.WOOL.id, "subtype": TEST_RED},
        {"direction": Direction.North, "material": block.WOOL.id, "subtype": TEST_RED},
        {"direction": Direction.East,  "material": block.WOOL.id, "subtype": TEST_BLUE},
        {"direction": Direction.West,  "material": block.WOOL.id, "subtype": TEST_BLUE},
    ]
    origin_x = TEST_ORIGIN_X
    origin_y = TEST_ORIGIN_Y
    origin_z = TEST_ORIGIN_Z
    _definition = rectangle_basics[0]

    rectangle_definition = RectangleDefinition()
    rectangle_definition.origin = Vec3(origin_x, origin_y, origin_z)
    rectangle_definition.length = TEST_WALL_LENGTH
    rectangle_definition.height = TEST_WALL_HEIGHT
    rectangle_definition.xz_angle = _definition["direction"]
    rec_left = Rectangle(rectangle_definition)

    origin_x -= 10
    rectangle_definition.origin = Vec3(origin_x, origin_y, origin_z)
    rec_right = Rectangle(rectangle_definition)

    origin_x -= 10
    rectangle_definition.origin = Vec3(origin_x, origin_y, origin_z)
    rec_flip = Rectangle(rectangle_definition)

    origin_x -= 10
    rectangle_definition.origin = Vec3(origin_x, origin_y, origin_z)
    rec_flip_origin = Rectangle(rectangle_definition)

    rec_left.draw(TEST_MATERIAL, TEST_RED)
    rec_left._draw_origin()

    rec_left.rotateLeft()
    rec_left.draw(TEST_MATERIAL, TEST_BLUE)

    rec_left.rotateLeft()
    rec_left.draw(TEST_MATERIAL, TEST_YELLOW)

    rec_right.draw(TEST_MATERIAL, TEST_RED)
    rec_right._draw_origin()

    rec_right.rotateRight()
    rec_right.draw(TEST_MATERIAL, TEST_BLUE)

    rec_right.rotateRight()
    rec_right.draw(TEST_MATERIAL, TEST_YELLOW)

    rec_flip.draw(TEST_MATERIAL, TEST_RED)
    rec_flip._draw_origin()

    rec_flip.flip()
    rec_flip.draw(TEST_MATERIAL, TEST_BLUE)
    rec_flip._draw_origin()

    rec_flip_origin.draw(TEST_MATERIAL, TEST_RED)
    rec_flip_origin._draw_origin()

    rec_flip_origin.flip_origin()
    rec_flip_origin.shift(-2)

    rec_flip_origin.draw(TEST_MATERIAL, TEST_BLUE)
    rec_flip_origin._draw_origin()


def test_rectangle_math():
    mc.postToChat("Testing rectangle math")

    rectangle_basics = [
        {"direction": Direction.South, "material": block.WOOL.id, "subtype": TEST_RED},
        {"direction": Direction.North, "material": block.WOOL.id, "subtype": TEST_RED},
        {"direction": Direction.East,  "material": block.WOOL.id, "subtype": TEST_BLUE},
        {"direction": Direction.West,  "material": block.WOOL.id, "subtype": TEST_BLUE},
    ]
    origin_x = TEST_ORIGIN_X
    origin_y = TEST_ORIGIN_Y
    origin_z = TEST_ORIGIN_Z
    _definition = rectangle_basics[0]

    rectangle_definition = RectangleDefinition()
    rectangle_definition.origin = Vec3(origin_x, origin_y, origin_z)
    rectangle_definition.length = TEST_WALL_LENGTH
    rectangle_definition.height = TEST_WALL_HEIGHT
    rectangle_definition.xz_angle = _definition["direction"]
    rec_mp = Rectangle(rectangle_definition)

    origin_x -= 10
    rectangle_definition.origin = Vec3(origin_x, origin_y, origin_z)
    rec_along = Rectangle(rectangle_definition)

    rec_mp.draw(TEST_MATERIAL, TEST_RED)
    mp_x, mp_y, mp_z = rec_mp.midpoint()
    mc.setBlock(mp_x, mp_y, mp_z, TEST_MATERIAL, TEST_YELLOW)
    print(f"Rectangle midpoint: {rec_mp.midpoint()}")

    rec_along.draw(TEST_MATERIAL, TEST_RED)
    along_x, along_y, along_z = rec_along.along(2)
    mc.setBlock(along_x, along_y, along_z, TEST_MATERIAL, TEST_YELLOW)
    along_x, along_y, along_z = rec_along.along(4)
    mc.setBlock(along_x, along_y, along_z, TEST_MATERIAL, TEST_YELLOW)

    rec_along.shift(0, 0, -5)
    rec_along.rotateRight()
    rec_along.draw(TEST_MATERIAL, TEST_RED)
    along_x, along_y, along_z = rec_along.along(2)
    mc.setBlock(along_x, along_y, along_z, TEST_MATERIAL, TEST_YELLOW)
    along_x, along_y, along_z = rec_along.along(4)
    mc.setBlock(along_x, along_y, along_z, TEST_MATERIAL, TEST_YELLOW)

    rec_along.shift(0, 0, -5)
    rec_along.flip()
    rec_along.draw(TEST_MATERIAL, TEST_RED)
    along_x, along_y, along_z = rec_along.along(2)
    mc.setBlock(along_x, along_y, along_z, TEST_MATERIAL, TEST_YELLOW)
    along_x, along_y, along_z = rec_along.along(4)
    mc.setBlock(along_x, along_y, along_z, TEST_MATERIAL, TEST_YELLOW)


def test_floor():
    floor_def = FloorDefinition()
    floor_def.origin = TEST_ORIGIN - Vec3(0, 1, 0)
    floor_def.width = 10  # Width of the lot
    floor_def.depth = 2  # Length of the lot
    floor_def.height = 15  # Space above the lot
    floor_def.length = 0  # Not used?
    floor_def.thickness = 3  # Depth into the ground
    floor_def.xz_angle = Direction.North
    floor_def.base_material = TEST_MATERIAL
    floor_def.base_material_subtype = TEST_BLUE

    ground = Floor(floor_def)
    ground.clear()


def main():
    ''' Main function '''
    debug_clear_space()
    test_rectangle_directions()
#    test_tipped_rectangles()
#    test_rectangle_rotate()
#    test_rectangle_math()
#    test_floor()
    halt

    # Build out the lot
    site_def = FloorDefinition()
    site_def.name = "LOT_DEFINITION"
    site_def.origin = Vec3(0, 0, 0)
    site_def.xz_angle = Direction.North
    site_def.width = 20
    site_def.height = 40
    site_def.depth = 30
    site_def.thickness = 3
    site_def.setback = 5
    site_def.base_material = block.GRASS.id
    print(f"{site_def}")

    lot = Site(site_def)
    lot.clear()
    lot._draw_origin(block.TNT.id)
    print(lot)

    # Build out the house foundation
    # Define the parameters of the house
    house_def = StructureDefinition()
    house_def.name = "HOUSE_DEFINITION"
    house_def.origin = None
    house_def.width = 7
    house_def.depth = 5
    house_def.story_height = 3
    house_def.exterior_wall_material = block.WOOD_PLANKS.id
    house_def.exterior_wall_subtype = 1
    house_def.exterior_corner_material = block.WOOD.id
    house_def.exterior_corner_subtype = 1
    house_def.interior_wall_material = block.SANDSTONE.id
    house_def.interior_wall_subtype = 1
    house_def.facing = Direction.East
    house_def.xz_angle = Direction.South  # BUGBUG: Remove this
    print(f"{house_def}")

    house = lot.add_structure(house_def)
    house.add_foundation(block.STONE.id, 1)
    house.foundation.clear()
    house.foundation._draw_origin(block.TNT.id)
    print(house)

    story_def = StoryDefinition()
    # BUGBUG: Move assignment of these properties to the story class from the parent class
    story_def.name = "STORY_DEFINITION"
    story_def.facing = house_def.facing
    story_def.width = house_def.width
    story_def.height = house_def.story_height
    story_def.origin = None
    print(story_def)

    first_floor = house.add_story(story_def)
    print(first_floor)
    first_floor._draw_origin(block.WOOL.id)

    # Define parameters for the walls
    wall_def = WallDefinition()
    wall_def.name = "EXTERIOR_WALL_DEFINITION"
    wall_def.length = house_def.width
    wall_def.height = house_def.story_height
    wall_def.wall_type = WallType.Exterior
    wall_def.material = block.WOOD_PLANKS.id
    wall_def.material_subtype = 1
    wall_def.corner_material = block.WOOD.id
    wall_def.corner_material_subtype = 0
    wall_def.origin = None
    wall_def.xz_angle = Direction.South
    print(f"{wall_def}")
    print(f"origin before add_wall {wall_def.origin}")
    wall = first_floor.add_wall(wall_def)
    wall._draw()
    print(wall)

    wall_def.xz_angle = Direction.East
    wall = first_floor.add_wall(wall_def)
    wall._draw()

    wall_def.xz_angle = Direction.West
    wall = first_floor.add_wall(wall_def)
    wall._draw()

    if False:
        #    x,y,z = site_def.origin
        #    mc.player.setPos(0,0,0)

        story = house.add_story(story_def)
        print(story)
    #    story._draw(block.MOSS_STONE.id)

        wall = story.add_wall(wall_def)
        wall._draw(block.BRICK_BLOCK.id)

        for wall in story.walls:
            print(f"{wall}")
            for window in wall.windows:
                print(f"\t{window}")
            for door in wall.doors:
                print(f"\t{door}")

            wall._draw(wall_material, wall_material_subtype)
            wall._draw_origin()

        # mc.setBlock(7.5,2,5,block.GRASS.id)


if __name__ == '__main__':
    main()
