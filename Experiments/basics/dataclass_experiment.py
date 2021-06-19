'''Experiments and examples on Python Data Classes
Reference:
https://bit.ly/3gBRRAl'''

from dataclasses import dataclass


@dataclass
class Coordinate():
    x:  int = 0
    y:  int = 0
    z:  int = 0
    name: str = "Coordinate"


@dataclass(frozen=True)
class Student():
    last_name: str


home = Coordinate(127, 128, 129)
print(f"Home before change: {home}")
home.x = 256
print(f"Home after change: {home}")

end_points = []
end_points.append(Coordinate(1, 2, 3))
end_points.append(Coordinate(x=5, y=6.2, z=7, name="Float for coordinate"))
end_points.append(Coordinate(x=5, y=6, z='z value', name="String for value"))
print(end_points)

first_student = Student("Smith")
print(first_student)
first_student.last_name = "Jones"   # <--- Yields an error
