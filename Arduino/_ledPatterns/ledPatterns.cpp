/*
  ledPatterns.cpp
  
  Builds on the ledMatrix class to display letters and patterns on an
  8x8 LED matrix.
  
  History:
  10/23/2014 -- Created using ledMatrix as a foundation.
  
  To Do:
  Use the ledMatrix class as a base class, instead of passing _led.
  
*/

#include "Arduino.h"
#include "ledMatrix.h"
#include "ledPatterns.h"



// 
// Constants
//

// Numeric constants providing a friendly name for the reference
// into the patterns array.
const byte patterns::checkbox  = 26;
const byte patterns::fill      = 27;
const byte patterns::checker   = 28;
const byte patterns::border    = 29;
const byte patterns::blank     = 30;


//
// These are the initializers for an array of constants defining shapes (and letters)
// to display on the LED matrix.
//
// Since C++ doesn't allow constants to be initialized in the class definition, they
// are declared in the definition, and initialized here.
//
// More sample code for constant arrays in C++ is here: https://www.gidforums.com/t-2981.html
//
  const byte patterns::_patternArray[][_numRows] =
  {
    {126,255,231,231,255,255,231,231},        // A
    {127,255,231,127,127,231,255,127},        // B
    {126,255,231,7,7,231,255,126},            // C
    {127,255,231,231,231,231,255,127},        // D
    {255,255,7,63,63,7,255,255},              // E
    {255,255,7,63,63,7,7,7},                  // F
    {126,255,231,7,247,231,255,126},          // G
    {231,231,231,255,255,231,231,231},        // H
    {28,28,28,28,28,28,28,28},                // I
    {224,224,224,224,224,224,252,124},        // J
    {199,231,119,63,63,119,231,199},          // K
    {7,7,7,7,7,7,255,255},                    // L
    {195,231,255,255,219,195,195,195},        // M
    {231,239,239,255,255,255,247,231},        // N
    {126,255,231,231,231,231,255,126},        // O
    {127,255,231,255,127,7,7,7},              // P
    {126,255,231,231,199,183,111,222},        // Q
    {127,255,231,255,127,231,231,231},        // R
    {126,255,7,127,254,224,255,126},          // S
    {127,127,28,28,28,28,28,28},              // T
    {231,231,231,231,231,231,255,126},        // U
    {231,231,231,231,231,231,126,60},         // V
    {195,195,219,219,219,255,126,52},         // W
    {231,231,126,60,60,126,231,231},          // X
    {231,231,231,126,60,24,24,24},            // Y
    {255,255,120,60,30,15,255,255},           // Z
    {255,195,165,153,153,165,195,255},        // Checkbox
    {255,255,255,255,255,255,255,255},        // All LEDs on
    {51,51,204,204,51,51,204,204},            // Checkerboard
    {255,129,129,129,129,129,129,255},        // Border
    {0,0,0,0,0,0,0,0}                         // Blank 
  };
  
  
  //
  // Class implementation
  //
  
  patterns::patterns()
  {
	  return;
  }


  //
  // Assigns the memory map array to the specified
  // pattern or letter from the global array.
  //
  void patterns::setShape(int shape)
  {
    int index=shape;
    
    switch (index)
    {
      case 'A' ... 'Z':                        // If the argument is an ASCII letter, map it
        index = index - 'A';                   // back to correct value in the global array.
        break;           
	  case ' ':
		  index = blank;
		  break;							   // Otherwise, leave it alone as it should be
    }                                          // a value from the list of friendly names.
    
    _led.setMatrix(_patternArray[index]);      // Set the LED matrix memory map to the array index.
    return;
  }
  
  
  //
  // Pass through function for outputting the memory map
  // to the physical LEDs.
  //
  void patterns::drawMatrix(boolean bounce, int speed)
  {
    _led.drawMatrix(bounce, speed);
    return; 
  }
