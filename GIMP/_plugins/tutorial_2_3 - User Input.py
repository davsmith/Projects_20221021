#!/usr/bin/env python

"""

GIMP Plugin Tutorial by Jackson Bates
https://www.youtube.com/watch?v=5Ld8Todog5s&t=0s

Runs two effects on an image with user input

Demonstrates:
- Retrieving and using user input

"""

# Though not preferred, import * is the conventional
# import method in GIMP plug-ins
from gimpfu import *

# Create debug logs in the temp directory
# The path may need to be updated for local device
import sys

sys.stderr = open("c:\\temp\\gimpstderr_t2_3.txt", "w")
sys.stdout = open("c:\\temp\\gimpstdout_t2_3.txt", "w")
print("Loaded Tutorial 2_3")


def extreme_unsharp_desaturation_tut3(image, drawable, radius, amount, mode):
    """
    The main function to output text to the error console
    """
    print("Entered extreme_unsharp_desaturation_tut3")

    # Start undo group
    pdb.gimp_image_undo_group_start(image)

    #    radius = 5.0
    #    amount = 5.0
    threshold = 0
    pdb.plug_in_unsharp_mask(image, drawable, radius, amount, threshold)

    # desaturate_mode = DESATURATE_LIGHTNESS
    pdb.gimp_desaturate_full(drawable, mode)

    pdb.gimp_image_undo_group_end(image)


register(
    "python-fu-extreme-unsharp-desaturation-tut3",
    "Unsharp mask and desaturate image",
    "Run an unsharp mask with user input",
    "Jackson Bates",
    "Jackson Bates",
    "2015",
    "Extreme unsharp and desaturate with input",  # <Image>/File/PluginName
    "RGB",  # type of image it works on (*, RGB, RGB*, RGBA, GRAY etc...)
    [
        # basic parameters are: (UI_ELEMENT, "variable", "label", Default)
        (PF_IMAGE, "image", "Takes current image", None),
        (PF_DRAWABLE, "drawable", "Input layer", None),
        (PF_SLIDER, "radius", "Radius", 5, (0, 500, 0.5)),
        (PF_SLIDER, "amount", "Amount", 5.0, (0, 10, 0.1)),
        (
            PF_RADIO,
            "mode",
            "Set desaturation mode:",
            DESATURATE_LIGHTNESS,
            (
                ("Lightness", DESATURATE_LIGHTNESS),
                ("Luminosity", DESATURATE_LUMINOSITY),
                ("Average", DESATURATE_AVERAGE),
            ),
        ),
    ],
    [],
    extreme_unsharp_desaturation_tut3,
    menu="<Image>/Filters/Enhance",
)  #

main()
