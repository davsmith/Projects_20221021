"""
    Pygame Tutorial from Tech with Tim channel on YouTube
    Link: https://www.youtube.com/playlist?list=PLzMcBGfZo4-lp3jAExUCewBfMx3UZFkh5
"""
import pygame

SCREEN_SIZE = SCREEN_X, SCREEN_Y = (500, 500)
TICK_TIME = 50
START_POS = (SCREEN_X / 2, SCREEN_Y / 2)
PLAYER_COLOR = pygame.color.THECOLORS['red']
SCREEN_COLOR = pygame.color.THECOLORS['black']
JUMP_INCREMENTS = 8
JUMP_SCALE = 0.5


def main():
    """ The main function called when run from the .py file instead of imported from a module """
    player_x, player_y = START_POS
    player_width = 64
    player_height = 64
    velocity = 5
    player_jump_step = 0
    player_is_jumping = False
    player_ascending = 1
    player_moving_left = False
    player_moving_right = False
    player_walk_count = 0

    pygame.init()

    win = pygame.display.set_mode(SCREEN_SIZE)
    pygame.display.set_caption("First Game")

    """ Load background and player images """
    background = pygame.image.load('resources\\bg.jpg')

    walkRight = []
    for i in range(1, 9):
        filename = f'resources\\R{i}.png'
        walkRight.append(pygame.image.load(filename))

    walkLeft = []
    for i in range(1, 9):
        filename = f'resources\\L{i}.png'
        walkLeft.append(pygame.image.load(filename))

    char = pygame.image.load('resources\\standing.png')

    run = True
    while run:
        # Sets a game clock so the game doesn't run too fast
        pygame.time.delay(TICK_TIME)

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                run = False

        # Use this instead of an event so we handle holding keys down rather
        # than just one event for each key down/key up
        keys = pygame.key.get_pressed()
        if keys[pygame.K_LEFT] and player_x > velocity:
            player_x -= velocity
        if keys[pygame.K_RIGHT] and player_x < SCREEN_X - player_width:
            player_x += velocity
        # if keys[pygame.K_UP]:
        #     player_y -= velocity
        # if keys[pygame.K_DOWN]:
        #     player_y += velocity
        if keys[pygame.K_SPACE] and not player_is_jumping:
            player_is_jumping = True
            player_ascending = 1
            player_jump_step = JUMP_INCREMENTS

        if player_is_jumping:
            player_y -= player_jump_step ** 2 * player_ascending * JUMP_SCALE
            player_jump_step -= 1
            if player_jump_step == 0:
                player_ascending = -1

            if player_jump_step < -JUMP_INCREMENTS:
                player_is_jumping = False

        redraw_game_window(win)

    pygame.quit()


def redraw_game_window(win):
    global walk_count
    global win

    win.blit(bg, (0, 0))
    pygame.draw.rect(win, PLAYER_COLOR,
                     (player_x, player_y, player_width, player_height))
    pygame.display.update()


if __name__ == "__main__":
    main()
