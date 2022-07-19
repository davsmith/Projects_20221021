''' Template for writing scripts for Minecraft Pi '''
from enum import Enum, unique
from mcpi.minecraft import Minecraft
from mcpi import block


@unique
class Cardinal(Enum):
    """Specifies the direction a an object along a compass"""
    North = 0
    East = 90
    South = 180
    West = 270
    Flat = -1


class Rectangle:
    ''' Definition of rectangular structure for MineCraft Pi '''

    def __init__(self, length, height, direction, material):
        self.length = length
        self.height = height
        self.direction = direction
        self.material = material


# The global Minecraft object
mc = Minecraft.create()


def demo_block():
    ''' Demonstrates the APIs associated with blocks '''

    # In the block module there are many different material types defined as constants
    # with the id set to the numeric value for the material ID
    # Some examples are block.SANDSTONE, block.AIR, block.GRASS
    #
    # Other integer values can be used as well
    #
    material = block.GOLD_BLOCK.id

    # Get the current position
    pl_x, pl_y, pl_z = mc.player.getPos()

    #
    # Single block actions
    #

    # Set the space South of the player's feet to gold
    mc.setBlock(pl_x, pl_y, pl_z+1, block.GOLD_BLOCK.id)

    # Set the space North of the player's feet to active dynamite
    mc.setBlock(pl_x, pl_y, pl_z-1, block.TNT.id, 1)

    # Set the space under the player's feet to bedrock
    mc.setBlock(pl_x, pl_y-1, pl_z, block.BEDROCK.id)

    #
    # Actions on multiple blocks (a cube)
    #
    # The cube is defined by opposite corners at x1, y1, z1 and x2, y2, z2
    # The x-coordinates indicate E/W with + to the East
    # The y-coordinates are U/D with y at the player's feet, y+1 at eye level and y-1 in the ground
    # The z-coordinates are N/S with + to the North
    #

    # Make a tower of bricks (3 blocks E/W, 4 blocks S/N, and 5 blocks tall) to the South of the player
    north_run = 4
    east_run = 3
    height = 5
    bottom = pl_y
    south = pl_z+1
    west = pl_x
    mc.setBlocks(west, bottom, south, west+east_run-1, bottom +
                 height-1, south+north_run-1, block.BRICK_BLOCK.id)


def draw_rectangle(length, height, direction=None, material=None, material_option=None,
                   origin=None,  thickness=None, flat=None):
    ''' Function to place a rectangle either vertically or horizontally (flat) '''

    if origin is None:
        origin = mc.player.getPos()

    if direction is None:
        direction = Cardinal.East

    if thickness is None:
        thickness = 1.0

    if material is None:
        material = block.SANDSTONE.id

    if material_option is None:
        material_option = 0

    if flat is None:
        flat = False

    if direction == Cardinal.East:
        if not flat:
            rx2 = origin.x + length - 1
            ry2 = origin.y + height - 1
            rz2 = origin.z + thickness - 1
        else:
            rx2 = origin.x + height - 1
            ry2 = origin.y - thickness + 1
            rz2 = origin.z + length - 1
    elif direction == Cardinal.North:
        if not flat:
            rx2 = origin.x + thickness - 1
            ry2 = origin.y + height - 1
            rz2 = origin.z + length - 1
        else:
            rx2 = origin.x + length - 1
            ry2 = origin.y - thickness + 1
            rz2 = origin.z - height + 1
    elif direction == Cardinal.West:
        if not flat:
            rx2 = origin.x - length + 1
            ry2 = origin.y + height - 1
            rz2 = origin.z + thickness - 1
        else:
            rx2 = origin.x - height + 1
            ry2 = origin.y - thickness + 1
            rz2 = origin.z - length + 1
    elif direction == Cardinal.South:
        if not flat:
            rx2 = origin.x + thickness - 1
            ry2 = origin.y + height - 1
            rz2 = origin.z - length + 1
        else:
            rx2 = origin.x - length + 1
            ry2 = origin.y - thickness + 1
            rz2 = origin.z + height - 1

    mc.setBlocks(origin.x, origin.y, origin.z, rx2,
                 ry2, rz2, material, material_option)


def bump_player():
    ''' Offsets player position by 1 in all directions '''
    player_x, player_y, player_z = mc.player.getPos()
    mc.player.setPos(player_x+1, player_y+1, player_z+1)


def main():
    ''' Main function '''
    pl_x, pl_y, pl_z = mc.player.getPos()
    mc.postToChat(f"Player is at ({pl_x}, {pl_y}, {pl_z})")
    draw_rectangle(10, 7, None, Cardinal.North, block.TNT.id, 2, True)
    draw_rectangle(10, 7, None, Cardinal.South, block.WOOD_PLANKS.id, 1, True)
    draw_rectangle(10, 7, None, Cardinal.East, block.SANDSTONE.id, 1, True)
    draw_rectangle(10, 7, None, Cardinal.West, block.MOSS_STONE.id, 1, True)


if __name__ == '__main__':
    main()
