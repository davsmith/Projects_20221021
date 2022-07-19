#!/usr/bin/env python

"""

GIMP Plugin Tutorial by Jackson Bates
https://www.youtube.com/watch?v=X0_a6U6PkCA&t=0s

Creates a Lomo effect by adjusting color channels

Demonstrates:
- Parsing GIMP docs (choosing the right method)
- Passing s-curves
- Using None instead of 0

"""

# Though not preferred, import * is the conventional
# import method in GIMP plug-ins
from gimpfu import *

# Create debug logs in the temp directory
# The path may need to be updated for local device
import sys

sys.stderr = open("c:\\temp\\gimpstderr_t2_4.txt", "w")
sys.stdout = open("c:\\temp\\gimpstdout_t2_4.txt", "w")
print("Loaded Tutorial 2_4")


def lomo(image, drawable):
    """
    The main function to output text to the error console
    """
    print("Entered lomo effect tutorial")

    # Start undo group
    pdb.gimp_image_undo_group_start(image)

    s_curve = (0, 0, 96, 64, 128, 128, 160, 192, 255, 255)
    inverted_s_curve = (0, 0, 64, 96, 128, 128, 192, 160, 255, 255)
    num_points = 10

    pdb.gimp_curves_spline(drawable, HISTOGRAM_RED, num_points, s_curve)
    pdb.gimp_curves_spline(drawable, HISTOGRAM_GREEN, num_points, s_curve)
    pdb.gimp_curves_spline(drawable, HISTOGRAM_BLUE, num_points, inverted_s_curve)

    # Add new layer and set to 'overlay'
    opacity_100 = 100
    layer = pdb.gimp_layer_new( image, image.width, image.height,
        RGB_IMAGE, "overlay", opacity_100, OVERLAY_MODE)

    layer_position = 0
    pdb.gimp_image_insert_layer(image, layer, None, layer_position)

    # Blend arguments and call to function
    blend_mode = 0
    paint_mode = 0
    gradient_type = 0
    offset = 0
    repeat = 0
    reverse = False
    supersample = False
    max_depth = 1
    threshold = 0
    dither = True
    x1 = layer.width
    y1 = 0
    x2 = layer.width
    y1 = 0
    x2 = layer.width
    y2 = layer.height
    pdb.gimp_edit_blend(layer, blend_mode, paint_mode, gradient_type,
                        opacity_100, offset, repeat, reverse, supersample,
                        max_depth, threshold, dither, x1, y1, x2, y2)

    # Merge all layers
    layer = pdb.gimp_image_merge_visible_layers(image, 0)
    pdb.gimp_image_undo_group_end(image)

register(
    "python-fu-lomo",
    "Tutorial 2-4: Lomo effect",
    "Creates a lomo effect on a given image",
    "Jackson Bates", "Jackson Bates", "2015",
    "Tutorial 2-4: Lomo",  # <Image>/File/PluginName
    "RGB",  # type of image it works on (*, RGB, RGB*, RGBA, GRAY etc...)
    [
        # basic parameters are: (UI_ELEMENT, "variable", "label", Default)
        (PF_IMAGE, "image", "Takes current image", None),
        (PF_DRAWABLE, "drawable", "Input layer", None),
    ],
    [],
    lomo,
    menu="<Image>/Examples",
)  #

main()
