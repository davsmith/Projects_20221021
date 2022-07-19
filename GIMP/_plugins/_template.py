#!/usr/bin/env python

'''
Template for a GIMP Python plug-in

To create a new plug-in copy this file to a .py file and
replace all values between <>

Based on tutorial at: https://www.youtube.com/watch?v=nmb-0KcgXzI

May 24, 2022 (Dave) - Added temporary files for script debugging
'''

# Though not preferred, import * is the conventional
# import method in GIMP plug-ins
from gimpfu import *

# Create debug logs in the temp directory
# The path may need to be updated for local device
import sys
sys.stderr = open( 'c:\\temp\\gimpstderr_<UNIQUE>.txt', 'w')
sys.stdout = open( 'c:\\temp\\gimpstdout_<UNIQUE>.txt', 'w')
print("Loaded <BASE NAME FOR MENU>")

def <NAME_OF_MAIN_FUNCTION>(image, drawable):
'''
    The main function for the plug-in, as defined in
    the register function below.
    
    The list of arguments is defined in the register function
    
'''

    print("Entered main function for <UNIQUE>")
    

register(
    "python-fu-<NAME-OF-MAIN-FUNCTION>", # Use - to separate words
    "<SHORT DESCRIPTION>",
    "<LONG DESCRIPTION>",
    "Dave Smith", "Dave Smith", "2022",
    "<MENU PATH>", # e.g. <Image>/File/PluginName
    "", # type of image it works on (*, RGB, RGB*, RGBA, GRAY etc...)
    [
        # basic parameters are: (UI_ELEMENT, "variable", "label", Default)
        (PF_IMAGE, "image", "takes current image", None),
        (PF_DRAWABLE, "drawable", "Input layer", None)
        # PF_SLIDER, SPINNER have an extra tuple (min, max, step)
        # PF_RADIO has an extra tuples within a tuple:
        #   eg. (("radio_label", "radio_value), ...) for as many radio buttons
        # PF_OPTION has an extra tuple containing options in drop-down list
        #   eg. ("opt1", "opt2", ...) for as many options
        # see ui_examples_1.py and ui_examples_2.py for live examples
    ],
    [],
    <NAME_OF_MAIN_FUNCTION>,")

main()