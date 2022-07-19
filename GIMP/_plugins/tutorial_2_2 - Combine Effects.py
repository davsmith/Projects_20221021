#!/usr/bin/env python

"""

GIMP Plugin Tutorial by Jackson Bates
https://www.youtube.com/watch?v=uSt80abcmJs&t=0s

Writes a string to the GIMP Error Console (dockable dialog)

Demonstrates:
- Building an algorithm from GIMP manual steps
- Determining the GIMP API to use
- Calling GIMP methods
- Using _ instead of -
- Using undo groups

"""

# Though not preferred, import * is the conventional
# import method in GIMP plug-ins
from gimpfu import *

# Create debug logs in the temp directory
# The path may need to be updated for local device
import sys

sys.stderr = open("c:\\temp\\gimpstderr_t2_2.txt", "w")
sys.stdout = open("c:\\temp\\gimpstdout_t2_2.txt", "w")
print("Loaded Tutorial 2_2")


def extreme_unsharp_desaturation_tut(image, drawable):
    """
    The main function to output text to the error console
    """
    print("Entered extreme_unsharp_desaturation_tut")

    # Start undo group
    pdb.gimp_image_undo_group_start(image)

    radius = 5.0
    amount = 5.0
    threshold = 0
#    pdb.plug_in_unsharp_mask(image, drawable, radius, amount, threshold)

    desaturate_mode = DESATURATE_LIGHTNESS
    pdb.gimp_desaturate_full(drawable, desaturate_mode)

    pdb.gimp_image_undo_group_end(image)


register(
    "python-fu-extreme-unsharp-desaturation-tut",
    "Unsharp mask and desaturate image",
    "Run an unsharp mask with amount set to 5, then desaturate image",
    "Jackson Bates", "Jackson Bates", "2015",
    "Extreme unsharp and desaturate",  # <Image>/File/PluginName
    "RGB",  # type of image it works on (*, RGB, RGB*, RGBA, GRAY etc...)
    [
        # basic parameters are: (UI_ELEMENT, "variable", "label", Default)
        (PF_IMAGE, "image", "Takes current image", None),
        (PF_DRAWABLE, "drawable", "Input layer", None),
    ],
    [],
    extreme_unsharp_desaturation_tut, menu="<Image>/Filters/Enhance",
)  #

main()
