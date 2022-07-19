import pygame

screenSize = screenSizeX, screenSizeY = 1000, 600
cellSize = cellX, cellY = 100, 100
gridSize = gridX, gridY = 3, 3
gridColor = (51, 51, 51)

textWindowWidth = 400
textWindowHeight = 600

canvasWidth = screenSizeX - textWindowWidth
canvasHeight = screenSizeY
canvasColor = (200,200,200)

offsetX = (canvasWidth - (cellX * gridX)) / 2
offsetY = (canvasHeight - (cellY * gridY)) / 2

pygame.init()

screen = pygame.display.set_mode((screenSizeX, screenSizeY))
pygame.display.set_caption("Grid Puzzle 2")

running = True
while (running):
    for event in pygame.event.get():
        if (event.type == pygame.QUIT):
            running = False

    screen.fill(canvasColor)
    for i in range(0, gridX):
        for j in range(0, gridY):
            pygame.draw.rect(screen, gridColor, pygame.Rect(i*cellX+offsetX,(j*cellY+offsetY),cellX,cellY), 2)
    pygame.draw.rect(screen, (50,50,50), pygame.Rect(screenSizeX-textWindowWidth, 0, textWindowWidth, textWindowHeight) )
    pygame.display.update()
