"""
    Using enumerated types in Python.

    Reference:
    -   Tutorial on enum: http://bit.ly/38OWu4Q
    -   Python docs for enum: https://docs.python.org/3/library/enum.html

"""
import enum
from enum import Enum, unique


@unique
class Suit(Enum):
    """
        A class defining an enumerated type for a set of card suits

        The @unique decorator ensures all of the values in the enumerated type are unique.

    Args:
        Enum (Enum): The super class from which enumerated types inherit
    """
    Club = 1
    Diamond = 2
    Heart = 3
    Spade = 4


def main():
    """ Main function to be run when module is run as a program """
    card_suit = Suit.Spade
    print(card_suit.name + " : " + str(card_suit.value))

    if card_suit == Suit.Heart:
        print("It's a heart")
    elif card_suit == Suit.Spade:
        print("It's a spade")
    elif card_suit == Suit.Club:
        print("It's a Club")
    elif card_suit == Suit.Diamond:
        print("It's a Diamond")

    card_suit = 'Heart'
    print("The value of " + card_suit + " is " + repr(Suit[card_suit]))

    print("\nListing the values in suit...")
    for one_suit in Suit:
        print(one_suit)


print(__file__)

if __name__ == '__main__':
    main()
