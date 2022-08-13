""" Experimenting with raising and catching exceptions """


def main():
    denominators = [1, 2, 3, 4, 5, 0]

    print("***** Trying to divide 5 by a set of numbers with 'else' *****")
    for denominator in denominators:
        try:
            print(
                f"Dividing 5 by {denominator}.  The result is {5/denominator}")
        except ZeroDivisionError:
            print("There was division by zero.")
        else:
            print("The division completed successfully")

    print("\n\n***** Trying to divide 5 by a set of numbers with 'finally' *****")
    for denominator in denominators:
        try:
            print(
                f"Dividing 5 by {denominator}.  The result is {5/denominator}")
        except ZeroDivisionError:
            print("There was division by zero.")
        finally:
            print("Attempted all divisions")


if __name__ == "__main__":
    main()
