from mcpi.minecraft import Minecraft
from mcpi import block
import time
import pygame

# The world dimensions change from world to world
# Setting blocks outside the bounds of the world seems to work ok
# Setting position outside the bounds of the world gets Steve stuck

class World():
    def __init__(self, greeting=None):
        self.mc = Minecraft.create()
        
        if not greeting is None:
            self.mc.postToChat(greeting)
            
        self.calc_bounds()

    def calc_bounds(self):
        x = -80
        block_type = 0
        while (block_type != 95) and (x > -250):
            x -= 1
            block_type = self.mc.getBlock(x,0,0)
        self.min_x = x
        self.max_x = x + 256

        self.min_y = -65
        self.max_y = 130

        z = -120
        block_type = 0
        while (block_type != 95) and (z > -250):
            z -= 1
            block_type = self.mc.getBlock(0,0,z)
        self.min_z = z
        self.max_z = z + 256

    def destroy_world(self, message=None):
        if (not message is None):
            self.mc.postToChat(message)
        self.mc.setBlocks(self.min_x, self.min_y, self.min_z,
                    self.max_x, self.max_y, self.max_z, 0)

        
    def create_plane(self, elevation=None, block_type=None, width=None, depth=None, thickness=None):
        x, y, z = self.mc.player.getPos()

        if elevation is None:
            elevation = y - 1
            
        if block_type is None:
            block_type = 1
        
        if width is None:
            plane_min_x = self.min_x
            plane_max_x = self.max_x
        else:
            plane_min_x = x
            plane_max_x = x + width
        
        if depth is None:
            plane_min_z = self.min_z
            plane_max_z = self.max_z
        else:
            plane_min_z = z
            plane_max_z = z + depth
            
        if thickness is None:
            thickness = 1
            
        self.mc.setBlocks(plane_min_x, elevation, plane_min_z,
                              plane_max_x, elevation - thickness + 1, plane_max_z, block_type)
        
    def list_surrounding_blocks(self):
        x, y, z = self.mc.player.getPos()
        print(f"Player at position: {x}, {y}, {z}")

new_world = World("Hello there!")
print(f"Min coords ({new_world.min_x},{new_world.min_y},{new_world.min_z})")
print(f"Max coords ({new_world.max_x},{new_world.max_y},{new_world.max_z})")

mc = new_world.mc
blockId = 1
ORIGIN = (0,0,0)

pygame.init()
pygame.display.set_mode((100,100))

pauseTime = 5
startTime = time.perf_counter()



running = True
while running:
    for event in pygame.event.get():
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_b:
                new_world.calc_bounds()
            if event.key == pygame.K_c:
                new_world.create_plane(None,4,10,15,1)
            if event.key == pygame.K_d:
                print("Tearing down the world")
                new_world.destroy_world("Goodbye world!")
                
                # Create a single block to stand on
                mc.setBlocks(0,0,0,0,0,0,1)

                # Put the player above the lone block
                print("Setting player position")
                mc.player.setPos(0,5,0)
            if event.key == pygame.K_o:
                mc.player.setPos(ORIGIN)
            if event.key == pygame.K_p:
                new_world.create_plane()
            if event.key == pygame.K_t:
                print(new_world.mc.entity.getTilePos())
            elif event.key == pygame.K_w:
                mc.player.setPos((-81.0,35,-127))
            elif event.key == pygame.K_x:
                print("Placing block of type " + str(blockId))
                x, y, z = mc.player.getPos()
                mc.setBlock(x+3, y, z, blockId)
            elif 48 <= event.key <= 57:
                blockId = event.key - 48
                print("Changed block id to " + str(blockId))
            elif event.key == pygame.K_LEFT:
                blockId = blockId - 1
            elif event.key == pygame.K_RIGHT:
                blockId = blockId + 1
            elif event.key == pygame.K_LESS:
                blockId = blockId - 10
            elif event.key == pygame.K_GREATER:
                blockId = blockId + 10
            elif event.key == pygame.K_q:
                mc.player.setPos((0,0,0))
            elif event.key == pygame.K_w:
                x, y, z = mc.player.getPos()
                x += 1
                mc.player.setPos((x, y, z))
            elif event.key == pygame.K_z:
                print("Removing some blocks")
                for xs in range(-110, 110):
                    for ys in range(-10,10):
                        for zs in range(-110,100):
                            print(f"Removing {xs},{ys},{zs}")
                            mc.setBlock(xs, ys, zs, 0)
                print("Done")
            elif event.key == pygame.K_v:
                x, y, z = mc.player.getPos()
                x = int(x)
                y = int(y)
                z = int(z)
                for xs in range(x-50, x+50):
                    for ys in range(y-5, y+5):
                        for zs in range (z-10, z+10):
                            print(f"Removing {xs},{ys},{zs}")
                            mc.setBlock(xs, ys, zs, 0)
                            
            else:
                print(event.key)
                
    timeElapsed = time.perf_counter() - startTime
    # print(timeElapsed)
    if timeElapsed > pauseTime:
        startTime = time.perf_counter()
        x, y, z = position = new_world.mc.player.getPos()
        print(f"Player is at position {x}, {y}, {z}")
#        print("Surrounding blocks are:")
#        x = int(x)
#        y = int(y)
#        z = int(z)
#        for zs in range(z-25, z+5):
#            print(f"({x},{y-1},{zs}): {mc.getBlock(x,y-1,zs)}")
