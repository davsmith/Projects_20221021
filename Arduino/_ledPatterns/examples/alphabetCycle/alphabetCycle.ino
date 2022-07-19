/*
  alphabetCycle.ino
  
  Example using the ledMatrix and ledPatterns library to cycle through the alphabet
  and some patterns on an 8x8 LED matrix.
  
  History:
  10/23/2014 -- Created using ledMatrix as a foundation.
  
  To Do:
  Use the ledMatrix class as a base class, instead of passing _led.
  
*/

#include "ledMatrix.h"
#include "ledPatterns.h"

  // Global variables and instances
  patterns pat;


  //
  // Main process
  //
    
  void setup()
  {
    Serial.begin(9600);                        // Initialize the serial port for debugging
  }
  
  
  void loop()
  {
    static unsigned long baseline = millis();
    static int index = 0;
    static int pause = 500;
    
    if ((millis() - baseline) > pause)
    {
      baseline = millis();


      index = index + 1;
      index = index % pat.blank;              // Use mod to wrap the index back to 0 if it gets bigger than the array
  }
    
    pat.setShape(index);                      // Populate the LED memory map from the global array
    pat.drawMatrix(false);                    // Output the memory map to the physical LED matrix
  }
