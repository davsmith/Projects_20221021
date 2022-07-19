# Game setup

# Import libraries
import pygame
from pygame import *

# Initialize pygame
pygame.init()

#------------------------------------------------
# Define constant variables
WINDOW_WIDTH = 1100
WINDOW_HEIGHT = 600
WINDOW_RES = (WINDOW_WIDTH, WINDOW_HEIGHT)

#------------------------------------------------
# Load assets

# Create window
GAME_WINDOW = display.set_mode(WINDOW_RES)
display.set_caption('Attack of the Joshs pizza army!')

# Set up the enemy image
# Load the image into the program
pizza_img = image.load('vampire.png')

# Convert the image to a surface
pizza_surf = Surface.convert_alpha(pizza_img)
VAMPIRE_PIZZA = transform.scale(pizza_surf, (100, 100))

# Draw the pizza on the screen
GAME_WINDOW.blit(VAMPIRE_PIZZA, (900, 400))

# Add a giant pepperoni
draw.circle(GAME_WINDOW, (255,0,0), (925, 425), 25, 0)

# Draw a brown rectangle for the lid
draw.rect(GAME_WINDOW, (160, 82, 45), (895, 390, 110, 110), 5)

# Draw a filled brown rectangle for the lid
draw.rect(GAME_WINDOW, (160, 82, 45), (895, 275, 110, 110), 0)


#------------------------------------------------
# Start the main game loop

# Game loop
game_running = True
while game_running:

# Check for events
    for event in pygame.event.get():
        # Exit loop on quit
        if event.type == QUIT:
            game_running = False

#------------------------------------------------
# Update the display
    display.update()

# End of main game loop
# ------------------------------------------
# Clean up game
pygame.quit()