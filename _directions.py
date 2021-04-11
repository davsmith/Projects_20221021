'''
Module to provide support for cardinal and rotational directions
'''

from enum import IntEnum


class Direction(IntEnum):
    ''' Class to provide support for directions '''
    North = 90
    West = 180
    East = 0
    South = 270

    def rotate_right(self):
        ''' Returns the value of the angle rotated clockwise by 90 degrees '''
        return self.value - 90

    def rotate_left(self):
        ''' Returns the value of the angle rotated counter clockwise by 90 degrees '''
        return self.value + 90

    def normalize_angle(self):
        ''' Converts an angle to a value between 0 and 360 '''
        while self.value <= 0:
            self.value += 360
        while self.value >= 360:
            self.value -= 360


def main():
    ''' Main function for test cases '''
    for direction in list(Direction):
        print(f"Direction: {direction.name}, value: {direction.value}")

    direction = Direction.North
    for rotation in range(0, 4):
        direction = None
        print(f"{rotation}, {direction}")


if __name__ == '__main__':
    main()
