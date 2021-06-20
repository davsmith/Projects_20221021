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
    
    def __post_init__(self):
        print("Coordinate has been defined")


@dataclass(frozen=True)
class Student():
    last_name: str
    first_name: str
    
@dataclass(frozen=True)
class CollegeStudent(Student):
    major: str

@dataclass(frozen=True)
class PhDStudent(CollegeStudent):
    thesis_topic: str

home = Coordinate(127, 128, 129)
print(f"Home before change: {home}")
home.x = 256
print(f"Home after change: {home}")

end_points = []
end_points.append(Coordinate(1, 2, 3))
end_points.append(Coordinate(x=5, y=6.2, z=7, name="Float for coordinate"))
end_points.append(Coordinate(x=5, y=6, z='z value', name="String for value"))
print(end_points)

science_guy = PhDStudent(major="communications", thesis_topic="Science!", last_name="Nye", first_name="Bill")
print(f"{science_guy}")

alien_student = PhDStudent("A","B","C","D")
print(f"{alien_student}")
#first_student = Student("Smith")
#print(first_student)
#first_student.last_name = "Jones"   # <--- Yields an error
