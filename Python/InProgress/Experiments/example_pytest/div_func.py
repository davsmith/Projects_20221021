""" Basic code against which to write unit tests """


def divide(val1, val2=1):
    """ Returns the first value divided by the second """
    return val1 / val2


if __name__ == "__main__":
    print(f"The result of divide is {divide(20,5)} ")
