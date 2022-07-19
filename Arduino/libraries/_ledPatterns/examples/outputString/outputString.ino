//
/*
  outputString.ino
  
  Example using the ledMatrix and ledPatterns library to output a string to
  an 8x8 LED matrix.
  
  History:
  10/29/2014 -- Created using the ledPatterns library.
  
  To Do:
  Use the ledMatrix class as a base class, instead of passing _led.
  
*/

#include "ledMatrix.h"
#include "ledPatterns.h"

  // Global variables and instances
  patterns pat;
  String inputString="HELLO";

  //
  // Main process
  //
    
  void setup()
  {
    Serial.begin(9600);                        // Initialize the serial port for debugging
    Serial.flush();
  }
  
  
  void loop()
  {
    static unsigned long baseline = millis();
    static int index = 0;
    static int pause = 500;
    static bool resetString=false;
    char ch;
    
    
    ch = Serial.read();
    if (ch > 0)
    {
      if (resetString)
      {
        resetString = false;
        inputString = "";
        index = 0;
      }
      
      inputString = inputString + ch;
      inputString.toUpperCase();
      Serial.println(inputString);
    }
    else
    {
      resetString = true;
    }
    
    if ((millis() - baseline) > pause)
    {
      baseline = millis();


      index = index + 1;
      index = index % inputString.length();              // Use mod to wrap the index back to 0 if it gets bigger than the array
  }
    
    pat.setShape(inputString[index]);                      // Populate the LED memory map from the global array
//    Serial.print("Sending ");
//    Serial.println(inputString[index]);
    pat.drawMatrix(false);                    // Output the memory map to the physical LED matrix
  }
