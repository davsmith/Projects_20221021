'''
Notes and sample code from article linked in readme.md
'''
import turtle
scr = turtle.Screen()
print(id(scr))
tur1 = turtle.Turtle()
tur1.color("blue")
tur1.forward(100)
tur1.left(90)
tur1.color("antiquewhite4")
tur1.forward(100)

tur2 = turtle.Turtle()
tur2.speed(1)
tur2.penup()
tur2.goto(-200, 100)
tur2.pendown()
tur2.color("green")
tur2.begin_fill()
for i in range(0, 4):
    tur2.right(90)
    tur2.forward(100)
tur2.end_fill()

turtle.done()
