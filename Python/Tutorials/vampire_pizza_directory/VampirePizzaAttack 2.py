# Resources from https://www.odddot.com/codethisgame

# Game setup

# Import libraries

# TODO: Figure out the difference between "import" and "from"
# TODO: Figure out if import * is bad coding practice
#
# Pygame modules used (not a complete list):
# sprite
#
# Pygame objects used (not a complete list):
# Surface

import pygame
from pygame import *
from random import randint


# Initialize the pygame library
pygame.init()

# Set up the clock
clock = time.Clock()

#------------------------------------------------
# Define constants
#------------------------------------------------

# Colors
WHITE = (255, 255, 255)

# Game window
WINDOW_WIDTH = 1100
WINDOW_HEIGHT = 600
WINDOW_RES = (WINDOW_WIDTH, WINDOW_HEIGHT)
FRAME_RATE = 60

# Grid size
GRID_ROWS = 6
GRID_COLUMNS = 11

# Tiles
WIDTH = 100
HEIGHT = 100

# Game logic
SPAWN_RATE = 360
STARTING_BUCKS = 15
BUCK_RATE = 120
STARTING_BUCK_BOOSTER = 1

# Monster speed
REG_SPEED = 2
SLOW_SPEED = 1

#------------------------------------------------
# Load assets
#------------------------------------------------

# Create the game window
# Setting the video mode is required before other Pygame functions can be used
GAME_WINDOW = display.set_mode(WINDOW_RES)
display.set_caption('Attack of the Joshs pizza army!')

# NOTE: Using an image uses 3 steps: load the image, create a surface, transform(scale) the image

# Set up background image
background_img = image.load('restaurant.jpg')
background_surf = Surface.convert_alpha(background_img)
BACKGROUND = transform.scale(background_surf, (WINDOW_RES))
GAME_WINDOW.blit(BACKGROUND, (0,0))

# Set up the game pieces (pizza and traps)
pizza_img = image.load('vampire.png')
pizza_surf = Surface.convert_alpha(pizza_img)
VAMPIRE_PIZZA = transform.scale(pizza_surf, (WIDTH, HEIGHT))

garlic_img = image.load('garlic.png')
garlic_surf = Surface.convert_alpha(garlic_img)
GARLIC = transform.scale(garlic_surf, (WIDTH, HEIGHT))

cutter_img = image.load('pizzacutter.png')
cutter_surf = Surface.convert_alpha(cutter_img)
CUTTER = transform.scale(cutter_surf, (WIDTH, HEIGHT))

pepperoni_img = image.load('pepperoni.png')
pepperoni_surf = Surface.convert_alpha(pepperoni_img)
PEPPERONI = transform.scale(pepperoni_surf, (WIDTH, HEIGHT))

#-------------------------------------------------------------------
# Define the classes
#
# - A base class (e.g. pygame.sprite.Sprite) can be passed to
#  the class definition as an argument
# - super().<method> references <method> on the base class
# - Class variables are defined outside method definitions (ref)
# - Instance variables are defined in a method and prefixed with self. (ref)
# - Variables in a method without self. prefix are local to the method
#-------------------------------------------------------------------

# Define the appearance and behavior of the vampire pizza sprite
class VampireSprite(sprite.Sprite):
    # Create an instance of the sprite and set parameters
    def __init__(self):
        # Call init on the parent (super) class
        super().__init__() # 128
        self.health = 100
        self.speed = REG_SPEED
        self.lane = randint(0, 4)
        y = 50 + self.lane * 100

        self.image = VAMPIRE_PIZZA.copy()
        self.rect = self.image.get_rect(center = (1100, y))
        all_vampires.add(self)

    # Move and draw the sprite on the background
    def update(self, game_window, counters):
        # Erase the previous display of the sprite by drawing the background
        game_window.blit(BACKGROUND, (self.rect.x, self.rect.y), self.rect)
        
        # Move the sprite (in the buffer)
        self.rect.x -= self.speed

        # Destroy the sprite if it's off the screen or has no health
        if self.health <= 0 or self.rect.x <= 100:
            self.kill()
        else:
            # Draw the sprite
            game_window.blit(self.image, (self.rect.x, self.rect.y))

    # Check if the sprite's tile has a trap and react appropriately
    def attack(self, tile):
        if tile.trap == SLOW:
            self.speed = SLOW_SPEED
        if tile.trap == DAMAGE:
            self.health -= 1


# Define behaviors that are time (frame) based
class Counters(object):
    def __init__(self, pizza_bucks, buck_rate, buck_booster):
        self.loop_count = 0
        self.display_font = font.Font('pizza_font.ttf', 25)  # TODO: Make this global?
        self.pizza_bucks = pizza_bucks
        self.buck_rate = buck_rate
        self.buck_booster = buck_booster
        self.bucks_rect = None
    
    # Called once per pass through the game loop.
    # Updates calculations and renders game stats (bucks)
    def update(self, game_window):
        self.loop_count += 1
        self.increment_bucks()
        self.draw_bucks(game_window)

    # Increment the pizza bucks based on the # times the update loop has run
    def increment_bucks(self):
            if self.loop_count % self.buck_rate == 0:
                self.pizza_bucks += self.buck_booster
                print('Incremented bucks to ' + str(self.pizza_bucks))

    # Display the count of pizza bucks on the game window
    def draw_bucks(self, game_window):
        # Erase the previous display by drawing the background over it
        if bool(self.bucks_rect):
            game_window.blit(BACKGROUND, (self.bucks_rect.x, self.bucks_rect.y), self.bucks_rect)
        
        # Create a surface with the text (in the buffer) but no position
        bucks_surf = self.display_font.render(str(self.pizza_bucks), True, WHITE)

        # Determine where on the screen to render (width is set from the text)
        self.bucks_rect = bucks_surf.get_rect()
        self.bucks_rect.x = WINDOW_WIDTH - 50
        self.bucks_rect.y = WINDOW_HEIGHT - 45

        # Display the amount of bucks
        game_window.blit(bucks_surf, self.bucks_rect)


# Define the different types of traps

# Class for generic trap
class Trap(object):
    def __init__(self, trap_kind, cost, trap_img):
        self.trap_kind = trap_kind
        self.cost = cost
        self.trap_img = trap_img


# TrapApplicator class
# Manages the selection of the current trap type based on player funds and trap cost
# There is a single instance of this class per game
class TrapApplicator(object):
    def __init__(self):
        self.selected = None

    # Sets the current trap type if the player can afford it (no rendering)
    def select_trap(self, trap):
        if trap.cost < counters.pizza_bucks:
            self.selected = trap
            print("Selected " + trap.trap_kind)
        else:
            print("You can't afford " + trap.trap_kind)
    
    # Marks the grid cell with a trap and calls set_trap to deduct funds and render
    def select_tile(self, tile, counters):
        self.selected = tile.set_trap(self.selected, counters)

# Base class for the individual tiles on the grid
class BackgroundTile(sprite.Sprite):
    def __init__(self, rect):
        super().__init__()
        self.trap = None
        self.rect = rect

# A subclass of BackgroundTile where the player can set traps
class PlayTile(BackgroundTile):
    def set_trap(self, trap, counters):
        if bool(trap) and not bool(self.trap):
                counters.pizza_bucks -= trap.cost
                self.trap = trap
                if trap == EARN:
                    counters.buck_booster += 1
        return None

    def draw_trap(self, game_window, trap_applicator):
        if bool(self.trap):
            game_window.blit(self.trap.trap_img, (self.rect.x, self.rect.y))

class ButtonTile(BackgroundTile):
    def set_trap(self, trap, counters):
        if counters.pizza_bucks >= self.trap.cost:
            return self.trap
        else:
            return None

    def draw_trap(self, game_window, trap_applicator):
        if bool(trap_applicator.selected):
            if trap_applicator.selected == self.trap:
                draw.rect(game_window, (238, 190, 47), (self.rect.x, self.rect.y, WIDTH, HEIGHT), 5)

class InactiveTile(BackgroundTile):
    def set_trap(self, trap, counters):
        return None

    def draw_trap(self, game_window, trap_applicator):
        pass
    
# --------------------------------------
# Create class instances and groups
# --------------------------------------

# Create a group for all the VampireSprite instances
all_vampires = sprite.Group()

counters = Counters(STARTING_BUCKS, BUCK_RATE, STARTING_BUCKS)
SLOW = Trap('SLOW', 5, GARLIC)
DAMAGE = Trap('DAMAGE', 3, CUTTER)
EARN = Trap('EARN', 7, PEPPERONI)

# Create an empty grid
tile_grid = []

trap_applicator = TrapApplicator()

# Draw the initial screen
GAME_WINDOW.blit(BACKGROUND, (0,0))

# Initialize and draw the background grid
tile_color = WHITE

for row in range(GRID_ROWS):
    # Create an empty list each time the loop runs
    row_of_tiles = []

    # Add each of the six lists (row_of_tiles) to the tile_grid list above
    tile_grid.append(row_of_tiles)
    for column in range(GRID_COLUMNS):
        # Create an invisible rect for each background tile sprite
        tile_rect = Rect(WIDTH * column, HEIGHT * row, WIDTH, HEIGHT)

        # Determine whether this cell is part of the game grid,
        # a menu item (button) or nothing
        
        # The first column is the pizza trucks so no action can be taken
        if column <= 1:
            new_tile = InactiveTile(tile_rect)
        else:
            # Put trap selection buttons in the bottom row
            if row == 5:
                if 2 <= column <= 4:
                    new_tile = ButtonTile(tile_rect)

                    # Assigns the trap to one of the trap types based on column
                    new_tile.trap = [SLOW, DAMAGE, EARN][column - 2]
                else:
                    new_tile = InactiveTile(tile_rect)
            else:
                new_tile = PlayTile(tile_rect)
        row_of_tiles.append(new_tile)

        # If the new tile is a button draw it on the screen
        if row == 5 and 2 <= column <= 4:
            BACKGROUND.blit(new_tile.trap.trap_img, (new_tile.rect.x, new_tile.rect.y))


        if column != 0 and row != 5:
            if column != 1:
                draw.rect(BACKGROUND, tile_color, (WIDTH * column, HEIGHT * row, WIDTH, HEIGHT), 1)


# ------------------------------------------------
# Start the main game loop

# Game loop
game_running = True
while game_running:

# Check for events
    for event in pygame.event.get():
        # Exit loop on quit
        if event.type == QUIT:
            game_running = False
        elif event.type == MOUSEBUTTONDOWN:
                coordinates = mouse.get_pos()
                x = coordinates[0]
                y = coordinates[1]

                tile_y = y // 100
                tile_x = x // 100
                trap_applicator.select_tile(tile_grid[tile_y][tile_x], counters)
                # print(x,y)
                print('You clicked tile x:' + str(tile_x) + '  y:' + str(tile_y))

    # Spawn vampire pizza sprites
    if randint(1, SPAWN_RATE) == 1:
            VampireSprite()

    for tile_row in tile_grid:
        for tile in tile_row:
            if bool(tile.trap):
                GAME_WINDOW.blit(BACKGROUND, (tile.rect.x, tile.rect.y), tile.rect)
    # -------------------------------------------------
    # Setup collision detection
    # list all vampires
    for vampire in all_vampires:
        tile_row = tile_grid[vampire.rect.y // 100]
        vamp_left_side = vampire.rect.x // 100
        vamp_right_side = (vampire.rect.x + vampire.rect.width) // 100
        if 0 <= vamp_left_side <= 10:
            left_tile = tile_row[vamp_left_side]
        else:
            left_tile = None

        if 0 <= vamp_right_side <= 10:
            right_tile = tile_row[vamp_right_side]
        else:
            right_tile = None

        if bool(left_tile):
                vampire.attack(left_tile)

        if bool(right_tile):
                if right_tile != left_tile:
                    vampire.attack(right_tile)
        
    # Update displays
    for vampire in all_vampires:
            vampire.update(GAME_WINDOW, counters)

            for tile_row in tile_grid:
                for tile in tile_row:
                    tile.draw_trap(GAME_WINDOW, trap_applicator)

    counters.update(GAME_WINDOW)
    display.update()

    # Set the frame rate
    clock.tick(FRAME_RATE)

# End of main game loop
# ------------------------------------------
# Clean up game
pygame.quit()