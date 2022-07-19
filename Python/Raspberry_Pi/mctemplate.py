''' Template for writing scripts for Minecraft Pi
'''
from mcpi.minecraft import Minecraft
from mcpi.minecraft import Block

AIR = 0
WOOD_PLANK = 5
GLASS = 20
GLASS_PANE = 102
CLAY = 82
BRICK = 45

FOUNDATION_MATERIAL = BRICK
WALL_MATERIAL = WOOD_PLANK
SPACE_MATERIAL = AIR

SPACE_SIZE = 12
FOUNDATION_SIZE = 10
HOUSE_WIDTH = 5
HOUSE_DEPTH = 5
HOUSE_HEIGHT = 3

OFFSET = 5

mc = Minecraft.create()

mc.player.setPos(9, 0, -3)
x, y, z = mc.player.getPos()
'''
mc.setBlocks(x-2, y-1, z-2, x+2, y-1, z+2, WOOD_PLANK)
mc.setBlocks(x-2, y-1, z-2, x+2, y-1, z+2, WOOD_PLANK)
mc.setBlocks(x-2, y-1, z-2, x+2, y-1, z+2, WOOD_PLANK)
mc.setBlocks(x-2, y-1, z-2, x+2, y-1, z+2, WOOD_PLANK)
mc.setBlocks(x-2, y-1, z-2, x+2, y-1, z+2, WOOD_PLANK)
'''
mc.setBlocks(x, y-2, z+1, x+SPACE_SIZE, y-2 +
             SPACE_SIZE, z+1+SPACE_SIZE, SPACE_MATERIAL)
mc.setBlocks(x, y-2, z+1, x+FOUNDATION_SIZE, y-2, z+1 +
             FOUNDATION_SIZE, FOUNDATION_MATERIAL)  # Foundation
mc.setBlocks(x+1, y-1, z+2, x+1+HOUSE_WIDTH, y-1 +
             HOUSE_HEIGHT, z+2, WALL_MATERIAL)  # Front wall
mc.setBlocks(x+1, y-1, z+2+HOUSE_DEPTH, x+1+HOUSE_WIDTH, y-1 +
             HOUSE_HEIGHT, z+2+HOUSE_DEPTH, WALL_MATERIAL)  # Front wall
mc.setBlocks(x+1, y-1, z+2, x+1, y-1+HOUSE_HEIGHT, z +
             2+HOUSE_DEPTH, WALL_MATERIAL)  # Right wall
mc.setBlocks(x+1+HOUSE_WIDTH, y-1, z+2, x+1+HOUSE_WIDTH, y-1 +
             HOUSE_HEIGHT, z+2+HOUSE_DEPTH, WALL_MATERIAL)  # Left wall
