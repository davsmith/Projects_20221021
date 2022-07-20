from mcpi.minecraft import Minecraft

# The world dimensions change from world to world
# Setting blocks outside the bounds of the world seems to work ok
# Setting position outside the bounds of the world gets Steve stuck
WORLD_MAX_X, WORLD_MAX_Y, WORLD_MAX_Z = (150, 20, 135)
WORLD_MIN_X, WORLD_MIN_Y, WORLD_MIN_Z = (-170, -63, -130)

class World():
    def __init__(self, greeting=None):
        self.mc = Minecraft.create()
        
        if not greeting is None:
            self.mc.postToChat(greeting)

    def destroy_world(self):
        self.mc.setBlocks(WORLD_MIN_X, WORLD_MIN_Y, WORLD_MIN_Z,
                    WORLD_MAX_X, WORLD_MAX_Y, WORLD_MAX_Z, 0)

        
    def create_plane(self, elevation, thickness, block_type=None):
        if block_type is None:
            block_type = 2
        self.mc.setBlocks(WORLD_MIN_X,-1,WORLD_MIN_Z,
                          WORLD_MAX_X,3,WORLD_MAX_Z, block_type )
        
    def list_surrounding_blocks(self):
        x, y, z = self.mc.player.getPos()
        print(f"Player at position: {x}, {y}, {z}")

new_world = World("Hello there!")
new_world.destroy_world()
new_world.list_surrounding_blocks()
#        self.mc.player.setPos((111,20,114))
#new_world.mc.player.setPos((-127,20,-127))
#new_world.mc.player.setPos((127,20,127))
#new_world.mc.player.setPos((100,WORLD_MAX_Y-2,100))
#new_world.mc.player.setPos((-100,WORLD_MAX_Y-5,-100))
#new_world.mc.player.setPos((-90,0,-90))
new_world.mc.setBlocks(0,-4,0,128,0,128,12   )
new_world.mc.player.setPos((90,0,90))
#mc.player.setPos((1,24,1))
new_world.mc.postToChat("Deconstruction complete.")
