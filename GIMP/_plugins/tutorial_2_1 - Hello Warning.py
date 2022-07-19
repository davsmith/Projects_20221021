#!/usr/bin/env python

"""

GIMP Plugin Tutorial by Jackson Bates
https://www.youtube.com/watch?v=nmb-0KcgXzI&t=0s

Writes a string to the GIMP Error Console (dockable dialog)

Demonstrates:
- Adding the error console to the the GIMP dock
- Writing a debug string to the error console

"""

# Though not preferred, import * is the conventional
# import method in GIMP plug-ins
from gimpfu import *

# Create debug logs in the temp directory
# The path may need to be updated for local device
import sys

sys.stderr = open("c:\\temp\\gimpstderr_t2_1.txt", "w")
sys.stdout = open("c:\\temp\\gimpstdout_t2_1.txt", "w")
print("Loaded Tutorial 2_1")


def hello_warning(image, drawable):
    """
    The main function to output text to the error console
    """
    print("Entered hello_warning")
    pdb.gimp_message("Hello world")
    pdb.gimp_message("Python version: {}".format(sys.version))
    pdb.gimp_message("Image dimensions: {}wx{}h".format(image.width, image.height))


register(
    "python-fu-hello-warning",
    "Hello world warning",
    "Prints 'Hello, world' to the error console",
    "Jackson Bates",
    "Jackson Bates",
    "2015",
    "Hello",  # <Image>/File/PluginName
    "",  # type of image it works on (*, RGB, RGB*, RGBA, GRAY etc...)
    [
        # basic parameters are: (UI_ELEMENT, "variable", "label", Default)
        (PF_IMAGE, "image", "Takes current image", None),
        (PF_DRAWABLE, "drawable", "Input layer", None),
    ],
    [],
    hello_warning,
    menu="<Image>/File",
)  #

main()
