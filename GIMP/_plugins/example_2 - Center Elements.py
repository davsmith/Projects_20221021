#! /usr/bin/env python2

from gimpfu import *

import sys

sys.stderr = open("c:\\temp\\gimpstderr_center_elements.txt", "w")
sys.stdout = open("c:\\temp\\gimpstdout_center_elements.txt", "w")
print("Loaded CENTER_ELEMENTS.py")


def center_elements_main(image, drawable, y_pos):
    print("Called center_elements_main")

    img2 = gimp.Image(250,250)
    print(img2.width)

    layers = []
    listAllVisible(image, layers)

    for layer in layers:
        pdb.gimp_layer_set_offsets(layer, image.width / 2 - layer.width / 2, y_pos)

    return


def listAllVisible(parent, outputList):
    for layer in parent.layers:
        if pdb.gimp_layer_get_visible(layer):
            outputList.append(layer)
            if pdb.gimp_item_is_group(layer):
                listAllVisible(layer, outputList)


register(
    "Center",
    "Center visible layers in the file.",
    "Center elements.",
    "Dave Smith",
    "Dave Smith",
    "2021",
    "<Image>/Examples/CenterElements",
    "*",
    [(PF_FLOAT, "y_pos", "Y Position:", 0)],
    [],
    center_elements_main,
)

main()
