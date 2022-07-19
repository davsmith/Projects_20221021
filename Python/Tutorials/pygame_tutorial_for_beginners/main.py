# From https://youtu.be/FfWpgLFMI7w
# Introduction to Pygame -- Writing a Space Invaders game
#
# Images come from http://flaticon.com

#
#
import pygame

# Initialize pygame which loads the sub modules
result = pygame.init()
print(result)

screen = pygame.display.set_mode((800,600))
pygame.display.set_caption('Space Invaders')
icon = pygame.image.load('ufo.png')
pygame.display.set_icon(icon)

playerImg = pygame.image.load('player.png')
playerX, playerY = 500, 480
playerSpeed = 0

def player(x, y):
    screen.blit(playerImg, (x, y))

running = True
while (running):
    screen.fill((0,0,0))

    playerX += playerSpeed

    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_LEFT:
                print("Left arrow is pressed")
                playerSpeed = -.3
            elif event.key == pygame.K_RIGHT:
                print("Right arrow is pressed")
                playerSpeed = .3
        if event.type == pygame.KEYUP:
            playerSpeed = 0

    player(playerX, playerY)
    pygame.display.update()
