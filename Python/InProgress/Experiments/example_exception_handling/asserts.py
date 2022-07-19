""" Sample code for demonstrating asserts and exception handling """


def kelvin_to_fahrenheit(temperature):
    """ Converts from kelvin to fahrenheit """
    assert (temperature >= 0), "Colder than absolute zero!"
    return ((temperature-273)*1.8)+32


print(kelvin_to_fahrenheit(273))
print(int(kelvin_to_fahrenheit(505.78)))
print(kelvin_to_fahrenheit(-5))

