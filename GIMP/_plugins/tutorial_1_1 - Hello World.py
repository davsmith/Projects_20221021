#!/usr/bin/env python

"""

GIMP Plugin Tutorial by Akkana Peck
https://www.youtube.com/watch?v=YHXX3KuB23Q&list=PLo0KUpJYWi6XvuvNXN2U-5zJr0PIEVwZc

Creates a new image around a text element with a user specified string

Demonstrates:
- Registering as a plug-in which creates images (rather than operates on existing)
- Creating and displaying a new image
- Creating text elements
- String, Font, Spinner, and color controls/arguments

May 24, 2022 (Dave Smith)
- Formatted to match other plug-in examples
- Added debug logs

"""

# Though not preferred, import * is the conventional
# import method in GIMP plug-ins
from gimpfu import *

# Create debug logs in the temp directory
# The path may need to be updated for local device
import sys

sys.stderr = open("c:\\temp\\gimpstderr_hello.txt", "w")
sys.stdout = open("c:\\temp\\gimpstdout_hello.txt", "w")
print("Loaded HELLO_WORLD")


def hello_world(initstr, font, size, color):
    """
    The main function to add a text element to the image
    """
    print("Entered hello_world")

    print(PIXELS)
    img = gimp.Image(1, 1, RGB)
    gimp.set_foreground(color)
    layer = pdb.gimp_text_fontname(
        img, None, 0, 0, initstr, 10, True, size, PIXELS, font
    )
    img.resize(layer.width, layer.height, 0, 0)
    gimp.Display(img)


register(
    "python_fu_hello_world",
    "Hello world image",
    "Creates an image with user specified text.",
    "Akkana Peck",
    "Akkana Peck",
    "2010",
    "Hello world...",  # <Image>/File/PluginName
    "",  # type of image it works on (*, RGB, RGB*, RGBA, GRAY etc...)
    [
        # basic parameters are: (UI_ELEMENT, "variable", "label", Default)
        (PF_STRING, "string", "String", "Hello, world!"),
        (PF_FONT, "font", "Font face", "Sans"),
        (PF_SPINNER, "size", "Font size", 50, (1, 3000, 1)),
        (PF_COLOR, "color", "Text color", (1.0, 0.0, 0.0)),
    ],
    [],
    hello_world,
    menu="<Image>/File/Create",
)  #

main()
