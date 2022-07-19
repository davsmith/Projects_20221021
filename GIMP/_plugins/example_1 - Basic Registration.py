#!/usr/bin/env python

'''
Basic GIMP plug-in to verify registration function
'''

from gimpfu import *

# Create debug logs in the temp directory
import sys
sys.stderr = open( 'c:\\temp\\ex1_basic_registration.txt', 'w')
sys.stdout = open( 'c:\\temp\\ex1_basic_registration.txt', 'w')
print("Loaded Basic_Registration")

def basic_registration_main(image, drawable):
    '''
    The main function for the plug-in, as defined in
    the register function below.
    
    The list of arguments is defined in the register function
    
    '''
    print("Entered main function for Basic_Registration")
    print(dir(gimp))
    

register(
    "python-fu-basic-registration",
    "Basic GIMP plug-in",
    "Simple plug-in to validate the register function",
    "Dave Smith", "Dave Smith", "2022",
    "<Image>/Examples/Ex1: Basic Registration",
    "", # type of image it works on ("", *, RGB, RGB*, RGBA, GRAY etc...)
    [
        # basic parameters are: (UI_ELEMENT, "variable", "label", Default)
        #(PF_IMAGE, "image", "takes current image", None),
        #(PF_DRAWABLE, "drawable", "Input layer", None)
        # PF_SLIDER, SPINNER have an extra tuple (min, max, step)
        # PF_RADIO has an extra tuples within a tuple:
        #   eg. (("radio_label", "radio_value), ...) for as many radio buttons
        # PF_OPTION has an extra tuple containing options in drop-down list
        #   eg. ("opt1", "opt2", ...) for as many options
        # see ui_examples_1.py and ui_examples_2.py for live examples
    ],
    [],
    basic_registration_main,)

def another_test():
    print("Hello")
    

main()