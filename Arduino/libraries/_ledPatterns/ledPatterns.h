/*
  ledPatterns.h
  
  Builds on the ledMatrix class to display letters and patterns on an
  8x8 LED matrix.
  
  History:
  10/23/2014 -- Created using ledMatrix as a foundation.
  
  To Do:
  Use the ledMatrix class as a base class, instead of passing _led.
  
*/

#ifndef ledPatterns_h
#define ledPatterns_h

#include "Arduino.h"
#include "ledMatrix.h"


#define arraySize(x) (sizeof(x)/sizeof(x[0]))

//
// Class definitions
//
class patterns
{
  private:
    static const  int        _numRows = 8;
                  ledMatrix  _led;
    static const  byte       _patternArray[][_numRows];        // The set of letters and patterns to display.  BUGBUG: Figure out why I can't use _led.numRows
    
  public:
    patterns();
    void setShape(int shape);
    void drawMatrix(boolean bounce, int speed=0);

    // Shapes
    static const  byte       blank;
    static const  byte       fill;
    static const  byte       checker;
    static const  byte       border;
    static const  byte       checkbox;
};

#endif
