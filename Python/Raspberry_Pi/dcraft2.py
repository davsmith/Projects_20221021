# Ground location: 58.2372,6.0,-96.5501
from mcpi.minecraft import Minecraft
mc = Minecraft.create()
mc.postToChat("Script started")
x, y, z = mc.player.getPos()
print(f"{x},{y},{z}")
# mc.player.setPos(58.2372,6.0,-96.5501)

