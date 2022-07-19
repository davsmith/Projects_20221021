#
# Icons
# Icons made by https://www.flaticon.com/authors/freepik

#  Turn off the Pygame welcome message
import os
os.environ["PYGAME_HIDE_SUPPORT_PROMPT"] = "1"

import math

def listModuleInits(header=""):
    print(header)
    print("  pygame.display: ", pygame.display.get_init())
    print("  pygame.font: ", pygame.font.get_init())
    print("  pygame.fastevent: ", pygame.fastevent.get_init())
    print("  pygame.joystick: ", pygame.joystick.get_init())
    print("  pygame.mixer: ", pygame.mixer.get_init())
    print("  pygame.scrap: ", pygame.scrap.get_init())
    # print("  pygame.midi: ", pygame.midi.get_init())
    # print("  pygame.cdrom: ", pygame.cdrom.get_init())
    print()


# Load the pygame module
import pygame
print("Pygame version: " + pygame.version.ver)

# Initialize the main pygame modules (display, font, joystick, ...)
listModuleInits("Before calling pygame.init()")
pygame.init()
listModuleInits("After calling pygame.init()")

#
# Rect class (https://www.pygame.org/docs/ref/rect.html)
#
# Summary:
# - Used for managing and taking action on rectangular spaces
#
# Interesting notes:
# - The _ip methods return nothing, and take action on the original rect
# - The non-_ip methods return a new rect and leave the original rect
#      in tact
#
left, top, width, height = 10, 20, 200, 400
speedX, speedY = 12, 14
rectFromCoords = pygame.Rect(left, top, width, height)
rectFromObject = pygame.Rect(rectFromCoords.move(22, 44))
rectCopy = rectFromCoords.copy()
rectMove = rectCopy.move(12, 14)
rectInflate = rectCopy.inflate(10, 10)

# Requires pygame 2.0.1
# rectUpdate = rectFromCoords.update(left+10, top+5, width-50, height+8)

print("Copy contains itself: " + str(rectCopy.contains(rectCopy)))
print("Inflated contains copy: " + str(rectInflate.contains(rectCopy)))
print("Copy contains inflated: " + str(rectCopy.contains(rectInflate)))
print("Point collides with copy: " + str(rectCopy.collidepoint(15, 25)))
print("Point collides with copy: " + str(rectCopy.collidepoint(5, 5)))
print()


#
# Color class (https://www.pygame.org/docs/ref/color.html)
#
red = pygame.Color(255, 0, 0)
print(f"Color -- Red:{red.r}, Green:{red.g}, Blue:{red.b}")


#
# Display module (https://www.pygame.org/docs/ref/display.html)
#
screen = pygame.display.set_mode((800,600))
icon = pygame.Surface((32,32))
icon.fill((128,0,128))
pygame.display.set_icon(icon)
pygame.display.set_caption("PyGame Test App")


#
# Surface class
# https://www.pygame.org/docs/ref/surface.html
#
smallSquare = pygame.Surface((50, 50))
smallSquare.fill((0,255,0))

bigSquare = pygame.Surface((200,200))
bigSquare.fill((255,0,0))

combined = bigSquare.copy()
combined.blit(smallSquare, (10,10))
combined.set_colorkey((0,255,0))

screen.fill((0,0,255))
screen.blit(bigSquare, (0,0))
screen.blit(smallSquare, (0,0))

screen.blit(combined, (200,200))

#
# Image class (https://www.pygame.org/docs/ref/image.html)
#
flask = pygame.image.load(".\\resources\\flask.png")
screen.blit(flask, (300,300))


#
# Draw module (https://www.pygame.org/docs/ref/draw.html)
#
square = pygame.Surface((30,30))
square.fill((50,50,50))
pygame.draw.rect(square,(255,0,0), pygame.Rect(0,0,15,15), 2)

screen.blit(square, (75,75))
pygame.draw.circle(screen, (0,255,0), (200,200), 5)
pygame.draw.polygon(screen, (0,0,255), [(300, 300), (325,300), (325,325)])
pygame.draw.ellipse(screen, (255,0,255), pygame.Rect(400,400,100,50))
pygame.draw.line(screen, (255,255,255), (200,10),(225,60), 4)
pygame.draw.aaline(screen, (255,255,255), (220,10),(245,60))

# Calculate the verticies of an n sided polygon (https://stackoverflow.com/questions/29064259/drawing-pentagon-hexagon-in-pygame)
def calcVerticies(n, center, radius, rotation=0):
    pi2 = 2 * 3.14

    # Calculate verticies
    verticies = []
    for i in range(0, n):
        x = (math.cos(pi2 * i/n + rotation) * radius) + center[0]
        y = (math.sin(pi2 * i/n + rotation) * radius) + center[1]
        verticies.append((x,y))

    return verticies

vert_list = calcVerticies(8, (600,100), 30)
pygame.draw.polygon(screen, (255, 0, 0), vert_list, 1)

#
# Event module (pygame.event)
#
# Keycode constants can be found here: https://www.pygame.org/docs/ref/key.html
#
running = True
while (running):
    has_quit = pygame.event.peek(pygame.QUIT)
    if (has_quit):
        print("I spied a QUIT event")
    for event in pygame.event.get():
        print(f"Extracted event {str(pygame.event.event_name(event.type))} ({event.type}) from the queue")
        if (event.type == pygame.QUIT):
            running = False
        if (event.type == pygame.DROPFILE):
            print(f"A file was dropped on the window.  File path: {event.__dict__['file']}")
        if (event.type == pygame.KEYDOWN):
            print("Key: " + str(event.key))
            if (event.key == pygame.K_SPACE):
                print("Space bar was pressed")
            elif (pygame.K_0 <= event.key <= pygame.K_9):
                num = event.key - pygame.K_0
                print(f"The number {num} was pressed")
        if (event.type == pygame.MOUSEMOTION):
            print(f"Mouse moved to coordinates {event.pos}")
                
    pygame.display.update()

