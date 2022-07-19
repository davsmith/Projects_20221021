''' Inheritance (Subclassing) (https://tinyurl.com/2pr49bpb) '''

class Vehicle():

    def __init__(self, make, model, year):
        self._make = make
        self._model = model
        self._year = year

    def set_weight(self, weight):
        self._weight = weight

    def print_stats(self):
        print(f'The vehicle is a {self._year} {self._make} {self._model}')

    def __add__(self, other):
        try:
            total_weight = self._weight + other._weight
        except AttributeError:
            print('Both vehicles must have the weight defined')
        else:
            return total_weight

class Truck(Vehicle):
    def __init__(self, make, model, year, cargo):
        self._capacity = cargo
        super().__init__(make, model, year)

    def add_connector_type(self, connector):
        self._connector = connector

    def print_stats(self):
        print(f'The truck is a {self._year} {self._make} {self._model}')
        print(f'  It can tow {self._capacity} pounds')

        # Print an nice message if the connector attribute doesn't exist (EAFP)
        try:
            print(f'  It has a {self._connector} connector')
        except AttributeError:
            print(f'  No connector information is available')

# Example 1:  Instantiate the base class with 3 arguments
veh1 = Vehicle('Honda', 'Civic', 2010)

# Example 2: Instantiate the subclass with 4 arguments
veh2 = Truck('Toyota', 'Tacoma', 2016, 10000)

# Call a method on the subclass, but not on the base class
veh2.add_connector_type('7-pin')

# Don't call the method to add the connector.
# Let the print_stats method (on the subclass) work it out
veh3 = Truck('Dodge', 'RAM', 2020, 8000)

veh1.print_stats()
veh2.print_stats()
veh3.print_stats()

if isinstance(veh3, Vehicle):
    print(f'Vehicle 3 is an instance of a Vehicle')

if isinstance(veh1, Truck):
    print(f'Vehicle 1 is a truck')
else:
    print(f'Vehicle 1 is not a truck')

if issubclass(Truck, Vehicle):
    print(f'Truck is a subclass of Vehicle')
else:
    print(f'Truck is not a subclass of Vehicle')

veh1.set_weight(2500)
veh2.set_weight(4500)
print(f'The total weight of Vehicle 1 and Vehicle 2 is: {veh1+veh2} pounds')