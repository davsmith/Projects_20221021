#!/usr/bin/env python

"""

GIMP Plugin Tutorial by Jackson Bates
https://www.youtube.com/watch?v=oNn9D_8d4zQ&t=0s

Creates a Lomo effect using user input

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

sys.stderr = open("c:\\temp\\tut2_5_Lomo_With_Input.txt", "w")
sys.stdout = open("c:\\temp\\tut2_5_Lomo_With_Input.txt", "w")
print("Loaded Lomo_With_Input")


def lomo_with_input(image, drawable, direction):
    """
    The main function to output text to the error console
    """
    print("Entered lomo_with_input tutorial")
    print("Direction: {}".format(direction))

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

    # Set parameeters based on the direction chosen by the user
    n = layer, blend_mode, paint_mode, gradient_type, opacity_100, offset, \
        repeat, reverse, supersample, max_depth, threshold, dither, \
        layer.width / 2, 0, layer.width / 2, layer.height / 2

    ne = layer, blend_mode, paint_mode, gradient_type, opacity_100, offset, \
        repeat, reverse, supersample, max_depth, threshold, dither, \
        layer.width / 2, 0, layer.width / 2, layer.height / 2

    e = layer, blend_mode, paint_mode, gradient_type, opacity_100, offset, \
        repeat, reverse, supersample, max_depth, threshold, dither, \
        layer.width, layer.height / 2, layer.width / 2, layer.height / 2

    s = layer, blend_mode, paint_mode, gradient_type, opacity_100, offset, \
        repeat, reverse, supersample, max_depth, threshold, dither, \
        layer.width / 2, layer.height, layer.width / 2, layer.height / 2

    w = layer, blend_mode, paint_mode, gradient_type, opacity_100, offset, \
        repeat, reverse, supersample, max_depth, threshold, dither, \
        0, layer.height / 2, layer.width / 2, layer.height / 2

    nw = layer, blend_mode, paint_mode, gradient_type, opacity_100, offset, \
        repeat, reverse, supersample, max_depth, threshold, dither, \
        0, 0, layer.width / 2, layer.height / 2

    if direction == 0:
        pdb.gimp_edit_blend(*n)
    elif direction == 1:
        pdb.gimp_edit_blend(*ne)
    elif direction == 2:
        pdb.gimp_edit_blend(*e)
    elif direction == 3:
        pdb.gimp_edit_blend(*se)
    elif direction == 4:
        pdb.gimp_edit_blend(*s)
    elif direction == 5:
        pdb.gimp_edit_blend(*sw)
    elif direction == 6:
        pdb.gimp_edit_blend(*w)
    else:
        pdb.gimp_edit_blend(*nw)

    # Merge all layers
    layer = pdb.gimp_image_merge_visible_layers(image, 0)
    pdb.gimp_image_undo_group_end(image)

register(
    "python-fu-lomo-with-input",
    "Tutorial 2-5: Lomo effect with input",
    "Creates a lomo effect on a given image based on user input",
    "Jackson Bates", "Jackson Bates", "2015",
    "Tutorial 2-5: Lomo with input...",  # <Image>/File/PluginName
    "*",  # type of image it works on (*, RGB, RGB*, RGBA, GRAY etc...)
    [
        # basic parameters are: (UI_ELEMENT, "variable", "label", Default)
        (PF_IMAGE, "image", "Takes current image", None),
        (PF_DRAWABLE, "drawable", "Input layer", None),
        (PF_OPTION, "direction", "Direction: ", 0,
            (
                ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
            )
        )
    ],
    [],
    lomo_with_input,
    menu="<Image>/Examples",
)  #

main()
